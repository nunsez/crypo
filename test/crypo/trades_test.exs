defmodule Crypo.TradesTest do
  use Crypo.DataCase

  alias Crypo.Trades

  describe "trades" do
    alias Crypo.Trades.Trade

    import Crypo.TradesFixtures

    @invalid_attrs %{symbol: nil, exchange_id: nil, order_id: nil, trade_id: nil, side: nil, cash_flow: nil, change: nil, price: nil, fee: nil, fee_rate: nil, transaction_time: nil}

    test "list_trades/0 returns all trades" do
      trade = trade_fixture()
      assert Trades.list_trades() == [trade]
    end

    test "get_trade!/1 returns the trade with given id" do
      trade = trade_fixture()
      assert Trades.get_trade!(trade.id) == trade
    end

    test "create_trade/1 with valid data creates a trade" do
      valid_attrs = %{symbol: "some symbol", exchange_id: "some exchange_id", order_id: "some order_id", trade_id: "some trade_id", side: "some side", cash_flow: 120.5, change: 120.5, price: 120.5, fee: 120.5, fee_rate: 120.5, transaction_time: ~U[2025-12-24 08:55:00.000000Z]}

      assert {:ok, %Trade{} = trade} = Trades.create_trade(valid_attrs)
      assert trade.symbol == "some symbol"
      assert trade.exchange_id == "some exchange_id"
      assert trade.order_id == "some order_id"
      assert trade.trade_id == "some trade_id"
      assert trade.side == "some side"
      assert trade.cash_flow == 120.5
      assert trade.change == 120.5
      assert trade.price == 120.5
      assert trade.fee == 120.5
      assert trade.fee_rate == 120.5
      assert trade.transaction_time == ~U[2025-12-24 08:55:00.000000Z]
    end

    test "create_trade/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Trades.create_trade(@invalid_attrs)
    end

    test "update_trade/2 with valid data updates the trade" do
      trade = trade_fixture()
      update_attrs = %{symbol: "some updated symbol", exchange_id: "some updated exchange_id", order_id: "some updated order_id", trade_id: "some updated trade_id", side: "some updated side", cash_flow: 456.7, change: 456.7, price: 456.7, fee: 456.7, fee_rate: 456.7, transaction_time: ~U[2025-12-25 08:55:00.000000Z]}

      assert {:ok, %Trade{} = trade} = Trades.update_trade(trade, update_attrs)
      assert trade.symbol == "some updated symbol"
      assert trade.exchange_id == "some updated exchange_id"
      assert trade.order_id == "some updated order_id"
      assert trade.trade_id == "some updated trade_id"
      assert trade.side == "some updated side"
      assert trade.cash_flow == 456.7
      assert trade.change == 456.7
      assert trade.price == 456.7
      assert trade.fee == 456.7
      assert trade.fee_rate == 456.7
      assert trade.transaction_time == ~U[2025-12-25 08:55:00.000000Z]
    end

    test "update_trade/2 with invalid data returns error changeset" do
      trade = trade_fixture()
      assert {:error, %Ecto.Changeset{}} = Trades.update_trade(trade, @invalid_attrs)
      assert trade == Trades.get_trade!(trade.id)
    end

    test "delete_trade/1 deletes the trade" do
      trade = trade_fixture()
      assert {:ok, %Trade{}} = Trades.delete_trade(trade)
      assert_raise Ecto.NoResultsError, fn -> Trades.get_trade!(trade.id) end
    end

    test "change_trade/1 returns a trade changeset" do
      trade = trade_fixture()
      assert %Ecto.Changeset{} = Trades.change_trade(trade)
    end
  end
end
