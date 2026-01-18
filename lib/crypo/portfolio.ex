defmodule Crypo.Portfolio do
  alias Crypo.Prices
  alias Crypo.Trades
  alias __MODULE__.FlopAdapter
  alias __MODULE__.Item

  def list!(params \\ %{}) do
    items = build() |> default_sort()
    Flop.validate_and_run!(items, params, adapter: FlopAdapter, replace_invalid_params: true)
  end

  def build do
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

        %Item{
          id: currency,
          symbol: symbol,
          currency: currency,
          balance: balance,
          buy_average: buy_average,
          my_cost: my_cost,
          current_price: current_price,
          current_cost: current_cost,
          pl_dollars: pl_dollars,
          pl_percent: pl_percent,
          share: 0.0
        }
      end)

    add_share(result)
  end

  # defp hide_low(items) do
  #   Enum.reject(items, fn item -> item.balance * item.buy_average < 1.0 end)
  # end

  defp add_share(items) do
    portfolio_cost = Enum.sum_by(items, fn item -> item.current_cost end)

    Enum.map(items, fn item ->
      %{item | share: Item.share(item, portfolio_cost)}
    end)
  end

  defp default_sort(items) do
    Enum.sort_by(items, fn item -> item.pl_dollars end)
  end
end
