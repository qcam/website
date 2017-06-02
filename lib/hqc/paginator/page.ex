defmodule HQC.Paginator.Page do
  @enforce_keys [
    :page_size,
    :page_number,
    :entries,
    :entry_count,
    :page_count
  ]

  defstruct @enforce_keys

  def has_next_page?(%__MODULE__{} = page) do
    page.page_number < page.page_count
  end

  def has_previous_page?(%__MODULE__{} = page) do
    page.page_number > 1
  end

  def next_page_number(%__MODULE__{} = page) do
    page.page_number + 1
  end

  def previous_page_number(%__MODULE__{} = page) do
    page.page_number - 1
  end
end
