defmodule Crypo.Prices.Sync do
  alias Crypo.BybitClient
  alias Crypo.Prices

  def xx do
    resp = BybitClient.get_tickers()

    case resp do
      %{body: %{"result" => %{"list" => list}}} ->
        handle_list(list)
    end
  end

  def handle_list(list) do
    prices = Prices.list_prices()
    prices_by_symbol = Map.new(prices, fn price -> {price.symbol, price} end)

    Enum.reduce(list, %{}, fn data, acc ->
      price = Map.get(prices_by_symbol, data["symbol"])

      if price do
        {last_price, _rest} = Float.parse(data["lastPrice"])
        changeset = Ecto.Changeset.change(price, %{price: last_price})
        # new_price = %{price | price: last_price}
        Map.put(acc, price.symbol, changeset)
      else
        acc
      end
    end)
  end
end
