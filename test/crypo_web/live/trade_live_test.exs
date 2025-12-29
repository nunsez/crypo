defmodule CrypoWeb.TradeLiveTest do
  use CrypoWeb.ConnCase

  import Phoenix.LiveViewTest
  import Crypo.TradesFixtures

  @create_attrs %{symbol: "some symbol", side: "some side", change: "some change", price: "some price", transaction_time: "some transaction_time"}
  @update_attrs %{symbol: "some updated symbol", side: "some updated side", change: "some updated change", price: "some updated price", transaction_time: "some updated transaction_time"}
  @invalid_attrs %{symbol: nil, side: nil, change: nil, price: nil, transaction_time: nil}
  defp create_trade(_) do
    trade = trade_fixture()

    %{trade: trade}
  end

  describe "Index" do
    setup [:create_trade]

    test "lists all trades", %{conn: conn, trade: trade} do
      {:ok, _index_live, html} = live(conn, ~p"/trades")

      assert html =~ "Listing Trades"
      assert html =~ trade.symbol
    end

    test "saves new trade", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/trades")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Trade")
               |> render_click()
               |> follow_redirect(conn, ~p"/trades/new")

      assert render(form_live) =~ "New Trade"

      assert form_live
             |> form("#trade-form", trade: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#trade-form", trade: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/trades")

      html = render(index_live)
      assert html =~ "Trade created successfully"
      assert html =~ "some symbol"
    end

    test "updates trade in listing", %{conn: conn, trade: trade} do
      {:ok, index_live, _html} = live(conn, ~p"/trades")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#trades-#{trade.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/trades/#{trade}/edit")

      assert render(form_live) =~ "Edit Trade"

      assert form_live
             |> form("#trade-form", trade: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#trade-form", trade: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/trades")

      html = render(index_live)
      assert html =~ "Trade updated successfully"
      assert html =~ "some updated symbol"
    end

    test "deletes trade in listing", %{conn: conn, trade: trade} do
      {:ok, index_live, _html} = live(conn, ~p"/trades")

      assert index_live |> element("#trades-#{trade.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#trades-#{trade.id}")
    end
  end

  describe "Show" do
    setup [:create_trade]

    test "displays trade", %{conn: conn, trade: trade} do
      {:ok, _show_live, html} = live(conn, ~p"/trades/#{trade}")

      assert html =~ "Show Trade"
      assert html =~ trade.symbol
    end

    test "updates trade and returns to show", %{conn: conn, trade: trade} do
      {:ok, show_live, _html} = live(conn, ~p"/trades/#{trade}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/trades/#{trade}/edit?return_to=show")

      assert render(form_live) =~ "Edit Trade"

      assert form_live
             |> form("#trade-form", trade: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#trade-form", trade: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/trades/#{trade}")

      html = render(show_live)
      assert html =~ "Trade updated successfully"
      assert html =~ "some updated symbol"
    end
  end
end
