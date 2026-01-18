defmodule Crypo.Portfolio.FlopAdapter do
  alias Crypo.Portfolio.Item

  @behaviour Flop.Adapter

  @impl true
  def init_backend_opts(_opts, _backend_opts, _caller_module) do
    raise "Module __using__ is not supported"
  end

  @impl true
  def init_schema_opts(_opts, _schema_opts, _caller_module, _struct) do
    raise "Module __deriving__ is not supported"
  end

  @impl true
  def fields(_struct, _adapter_opts) do
    raise "Module __deriving__ is not supported"
  end

  @impl true
  def get_field(_item, _field, _field_info) do
    raise "Module __deriving__ is not supported"
  end

  @impl true
  def apply_filter(_items, _filter, _struct, _opts) do
    raise "Filters is not supported"
  end

  @impl true
  def apply_order_by(items, prepared_directions, _opts) do
    Enum.sort(items, fn a, b -> Item.compare(a, b, prepared_directions, false) end)
  end

  @impl true
  def apply_limit_offset(items, limit, offset, _opts) do
    items = if offset, do: Enum.drop(items, offset), else: items
    if limit, do: Enum.take(items, limit), else: items
  end

  @impl true
  def apply_page_page_size(items, page, page_size, opts) do
    offset_for_page = (page - 1) * page_size
    apply_limit_offset(items, page_size, offset_for_page, opts) |> dbg()
  end

  @impl true
  def apply_cursor(items, cursor_fields, opts) do
    dbg({cursor_fields, opts})
    items
  end

  @impl true
  def list(items, _opts), do: items

  @impl true
  def count(items, _opts), do: length(items)
end
