defmodule CrypoWeb.PortfolioLive.Index do
  use CrypoWeb, :live_view

  alias Crypo.Prices
  alias Crypo.Trades
  alias Crypo.Portfolio

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>Portfolio</.header>

      <Flop.Phoenix.table
        items={@streams.portfolio}
        meta={@meta}
        opts={[table_attrs: [class: "table table-zebra"]]}
        on_sort={JS.push("sort-portfolio")}
      >
        <:col :let={{_id, item}} label="Currency" field={:currency}>
          <.link class="link link-primary" navigate={~p"/trades/#{item.symbol}"}>
            {item.currency}
          </.link>
        </:col>

        <:col :let={{_id, item}} label="Balance" field={:balance}>
          {format_number(item.balance)}
        </:col>

        <:col :let={{_id, item}} label="Buy Average" field={:buy_average}>
          {format_number(item.buy_average)}
        </:col>

        <:col :let={{_id, item}} label="My Cost" field={:my_cost}>
          {format_number(item.my_cost)}
        </:col>

        <:col :let={{_id, item}} label="Current price" field={:current_price}>
          {format_number(item.current_price)}
        </:col>

        <:col :let={{_id, item}} label="Current cost" field={:current_cost}>
          {format_number(item.current_cost)}
        </:col>

        <:col :let={{_id, item}} label="P&L $" field={:pl_dollars}>
          {format_number(item.pl_dollars)}
        </:col>

        <:col :let={{_id, item}} label="P&L %" field={:pl_percent}>
          {format_number(item.pl_percent)}
        </:col>

        <:col :let={{_id, item}} label="Share %" field={:share}>
          {item.share}
        </:col>
      </Flop.Phoenix.table>
    </Layouts.app>
    """
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {portfolio, meta} = Portfolio.list!(params)

    socket =
      socket
      |> stream(:portfolio, portfolio, reset: true)
      |> assign(:meta, meta)

    {:noreply, socket}
  end

  @impl true
  def handle_event("update-prices", _unsigned_params, socket) do
    data = Prices.Sync.xx()
    Prices.update_prices(data)

    flop = socket.assigns.meta.flop
    {portfolio, meta} = Portfolio.list!(flop)

    socket =
      socket
      |> stream(:portfolio, portfolio, reset: true)
      |> put_flash(:info, "Prices updated")
      |> assign(:meta, meta)

    Process.send_after(self(), {:clear_flash, :info}, to_timeout(second: 3))

    {:noreply, socket}
  end

  def handle_event("update-trades", _unsigned_params, socket) do
    Trades.Import.call()

    flop = socket.assigns.meta.flop
    {portfolio, meta} = Portfolio.list!(flop)

    socket =
      socket
      |> stream(:portfolio, portfolio, reset: true)
      |> put_flash(:info, "Trades updated")
      |> assign(:meta, meta)

    Process.send_after(self(), {:clear_flash, :info}, to_timeout(second: 3))

    {:noreply, socket}
  end

  def handle_event("sort-portfolio", unsigned_params, socket) do
    flop = Flop.push_order(socket.assigns.meta.flop, unsigned_params["order"])
    {portfolio, meta} = Portfolio.list!(flop)

    socket =
      socket
      |> stream(:portfolio, portfolio, reset: true)
      |> assign(:meta, meta)

    {:noreply, socket}
  end

  def handle_event("update-filter", params, socket) do
    params = Map.delete(params, "_target")
    dbg(params)
    {:noreply, push_patch(socket, to: ~p"/?#{params}")}
  end

  @impl true
  def handle_info({:clear_flash, key}, socket) do
    socket = if key, do: clear_flash(socket, key), else: clear_flash(socket)

    {:noreply, socket}
  end

  defp format_number(number) when is_number(number) do
    absolute = abs(number)

    cond do
      number == 0 -> "0"
      absolute < 0.001 -> :erlang.float_to_binary(number, decimals: 8)
      absolute < 1 -> :erlang.float_to_binary(number, decimals: 6)
      absolute < 1000 -> :erlang.float_to_binary(number, decimals: 2)
      true -> :erlang.float_to_binary(number, decimals: 2)
    end
  end

  defp format_number(_), do: "N/A"
end
