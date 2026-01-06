defmodule CrypoWeb.PortfolioLive.Index do
  use CrypoWeb, :live_view

  alias Crypo.Prices
  alias Crypo.Trades

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>Portfolio</.header>

      <.table
        id="portfolio"
        rows={@streams.portfolio}
      >
        <:col :let={{_id, item}} label="Currency">
          <.link class="link link-primary" navigate={~p"/trades/#{item.symbol}"}>
            {item.currency}
          </.link>
        </:col>

        <:col :let={{_id, item}} label="Balance">{format_number(item.balance)}</:col>
        <:col :let={{_id, item}} label="Buy Average">{format_number(item.buy_average)}</:col>
        <:col :let={{_id, item}} label="My Cost">{format_number(item.my_cost)}</:col>
        <:col :let={{_id, item}} label="Current price">{format_number(item.current_price)}</:col>
        <:col :let={{_id, item}} label="Current cost">{format_number(item.current_cost)}</:col>
        <:col :let={{_id, item}} label="P&L $">{format_number(item.pl_dollars)}</:col>
        <:col :let={{_id, item}} label="P&L %">{format_number(item.pl_percent)}</:col>
        <:col :let={{_id, item}} label="Share %">{item.share}</:col>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    portfolio = if connected?(socket), do: build_portfolio(), else: []

    socket =
      socket
      |> assign(:page_title, "Portfolio")
      |> stream(:portfolio, portfolio)

    {:ok, socket}
  end

  @impl true
  def handle_event("update-prices", _unsigned_params, socket) do
    data = Prices.Sync.xx()
    Prices.update_prices(data)

    socket =
      socket
      |> stream(:portfolio, build_portfolio(), reset: true)
      |> put_flash(:info, "Prices updated")

    {:noreply, socket}
  end

  def handle_event("update-trades", _unsigned_params, socket) do
    Trades.Import.call()

    socket =
      socket
      |> stream(:portfolio, build_portfolio(), reset: true)
      |> put_flash(:info, "Trades updated")

    {:noreply, socket}
  end

  defp build_portfolio() do
    trades = Trades.list_enabled_trades()
    prices = Prices.list_prices() |> Map.new(fn price -> {price.symbol, price} end)

    by_symbol = Enum.group_by(trades, fn trade -> trade.symbol end)

    result =
      Enum.map(by_symbol, fn {symbol, trades} ->
        currency = String.trim_trailing(symbol, "USDT")
        buy_trades = Enum.filter(trades, fn trade -> trade.side == "Buy" end)
        buy_cost = Enum.sum_by(buy_trades, fn trade -> trade.cash_flow * trade.price end)
        buy_count = Enum.sum_by(buy_trades, fn trade -> trade.change end)
        buy_average = buy_cost / buy_count

        sell_trades = Enum.filter(trades, fn trade -> trade.side == "Sell" end)
        sell_cost = -Enum.sum_by(sell_trades, fn trade -> trade.cash_flow * trade.price end)
        # sell_count = -Enum.sum_by(sell_trades, fn trade -> trade.change end)

        balance = Enum.sum_by(trades, fn trade -> trade.change end)

        current_price = if prices[symbol], do: prices[symbol].price, else: 0
        my_cost = buy_cost - sell_cost
        current_cost = balance * current_price
        pl_dollars = current_cost - my_cost
        pl_percent = pl_dollars * 100 / my_cost

        %{
          id: currency,
          currency: currency,
          symbol: symbol,
          balance: balance,
          buy_average: buy_average,
          my_cost: my_cost,
          current_price: current_price,
          current_cost: current_cost,
          pl_dollars: pl_dollars,
          pl_percent: pl_percent,
          share: 0
        }
      end)

    result = Enum.reject(result, fn item -> item.balance * item.buy_average < 1.0 end)
    portfolio_cost = Enum.sum_by(result, fn item -> item.current_cost end)

    result =
      Enum.map(result, fn item ->
        share =
          if portfolio_cost > 0 do
            Float.round(item.current_cost * 100 / portfolio_cost, 1)
          else
            0.0
          end

        %{item | share: share}
      end)

    Enum.sort_by(result, fn item -> item.pl_dollars end)
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
