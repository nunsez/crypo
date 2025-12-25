defmodule Crypo.TradesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Crypo.Trades` context.
  """

  @doc """
  Generate a trade.
  """
  def trade_fixture(attrs \\ %{}) do
    {:ok, trade} =
      attrs
      |> Enum.into(%{
        cash_flow: 120.5,
        change: 120.5,
        exchange_id: "some exchange_id",
        fee: 120.5,
        fee_rate: 120.5,
        order_id: "some order_id",
        price: 120.5,
        side: "some side",
        symbol: "some symbol",
        trade_id: "some trade_id",
        transaction_time: ~U[2025-12-24 08:55:00.000000Z]
      })
      |> Crypo.Trades.create_trade()

    trade
  end
end
