defmodule HQC.Paginator do
  def paginate(entries, page_number, page_size)
      when page_number > 0 and page_size > 0 do
    offset = page_size * (page_number - 1)
    entry_count = Enum.count(entries)

    %__MODULE__.Page{
      page_size: page_size,
      page_number: page_number,
      entries: Enum.slice(entries, offset, page_size),
      entry_count: entry_count,
      page_count: trunc(entry_count / page_size)
    }
  end
end
