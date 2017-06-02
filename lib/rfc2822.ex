defmodule RFC2822 do
  import NimbleParsec

  day =
    choice([
      string("Mon"),
      string("Tue"),
      string("Wed"),
      string("Thu"),
      string("Fri"),
      string("Sat"),
      string("Sun")
    ])
    |> string(",")
    |> string(" ")

  date =
    integer(min: 1, max: 2)
    |> ignore(string(" "))
    |> choice([
      string("Jan"),
      string("Feb"),
      string("Mar"),
      string("Apr"),
      string("May"),
      string("Jun"),
      string("Jul"),
      string("Aug"),
      string("Sep"),
      string("Oct"),
      string("Nov"),
      string("Dec")
    ])
    |> ignore(string(" "))
    |> integer(4)

  time =
    integer(2)
    |> ignore(string(":"))
    |> integer(2)
    |> ignore(string(":"))
    |> optional(integer(2))

  timezone =
    choice([
      string("UT"),
      string("GMT"),
      string("EST"),
      string("EDT"),
      string("CST"),
      string("CDT"),
      string("MST"),
      string("MDT"),
      choice([string("+"), string("-")])
      |> integer(2)
      |> integer(2)
    ])

  defparsec(
    :rfc2822,
    optional(ignore(day))
    |> concat(date)
    |> ignore(string(" "))
    |> concat(time)
    |> ignore(string(" "))
    |> concat(timezone)
  )

  def from_string(binary) do
    with {:ok, [day, month, year, hour, minute, second | zone], _, _, _, _} <- rfc2822(binary),
         {:ok, offset} <- zone_to_offset(zone),
         {:ok, naive_datetime} <-
           NaiveDateTime.new(year, month_from_string(month), day, hour, minute, second) do
      {:ok,
       naive_datetime
       |> NaiveDateTime.add(offset, :second)
       |> DateTime.from_naive!("Etc/UTC")}
    else
      _other -> {:error, :invalid}
    end
  end

  defp month_from_string("Jan"), do: 1
  defp month_from_string("Feb"), do: 2
  defp month_from_string("Mar"), do: 3
  defp month_from_string("Apr"), do: 4
  defp month_from_string("May"), do: 5
  defp month_from_string("Jun"), do: 6
  defp month_from_string("Jul"), do: 7
  defp month_from_string("Aug"), do: 8
  defp month_from_string("Sep"), do: 9
  defp month_from_string("Oct"), do: 10
  defp month_from_string("Nov"), do: 11
  defp month_from_string("Dec"), do: 12

  defp zone_to_offset(["UTC"]), do: {:ok, 0}
  defp zone_to_offset(["GMT"]), do: {:ok, 0}
  defp zone_to_offset(["EST"]), do: {:ok, 5 * 60 * 60}
  defp zone_to_offset(["EDT"]), do: {:ok, 4 * 60 * 60}
  defp zone_to_offset(["CST"]), do: {:ok, 6 * 60 * 60}
  defp zone_to_offset(["CDT"]), do: {:ok, 5 * 60 * 60}
  defp zone_to_offset(["MST"]), do: {:ok, 7 * 60 * 60}
  defp zone_to_offset(["MDT"]), do: {:ok, 6 * 60 * 60}
  defp zone_to_offset(["PST"]), do: {:ok, 8 * 60 * 60}
  defp zone_to_offset(["PDT"]), do: {:ok, 7 * 60 * 60}

  defp zone_to_offset(["-", hour, minute]) do
    {:ok, hour * 3_600 + minute * 60}
  end

  defp zone_to_offset(["+", hour, minute]) do
    {:ok, -(hour * 3_600 + minute * 60)}
  end

  defp zone_to_offset(_other), do: :error
end
