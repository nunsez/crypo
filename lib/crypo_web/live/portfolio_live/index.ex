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
        <:col :let={{_id, item}} label="Currency">{item.currency}</:col>
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
    {:ok,
     socket
     |> assign(:page_title, "Portfolio")
     |> stream(:portfolio, build_portfolio())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    portfolio = Trades.get_portfolio!(id)
    {:ok, _} = Trades.delete_portfolio(portfolio)

    {:noreply, stream_delete(socket, :trades, portfolio)}
  end

  defp build_portfolio() do
    trades = Trades.list_trades()
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
        sell_count = -Enum.sum_by(sell_trades, fn trade -> trade.change end)

        balance = Enum.sum_by(trades, fn trade -> trade.change end)
        current_price = prices[symbol].price || 0
        my_cost = buy_cost - sell_cost
        current_cost = balance * current_price
        pl_dollars = current_cost - my_cost
        pl_percent = pl_dollars * 100 / my_cost

        %{
          id: currency,
          currency: currency,
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
        share = Float.round(item.current_cost * 100 / portfolio_cost, 1)
        %{item | share: share}
      end)

    Enum.sort_by(result, fn item -> item.pl_dollars end)
  end

  defp format_number(number) when is_number(number) do
    cond do
      number == 0 -> "0"
      abs(number) < 0.001 -> :erlang.float_to_binary(number, decimals: 8)
      abs(number) < 1 -> :erlang.float_to_binary(number, decimals: 6)
      abs(number) < 1000 -> :erlang.float_to_binary(number, decimals: 2)
      true -> :erlang.float_to_binary(number, decimals: 2)
    end
  end

  defp format_number(_), do: "-"
end
