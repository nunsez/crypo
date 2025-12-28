defmodule CrypoWeb.PortfolioLiveTest do
  use CrypoWeb.ConnCase

  import Phoenix.LiveViewTest
  import Crypo.TradesFixtures

  @create_attrs %{foo: "some foo", bar: "some bar"}
  @update_attrs %{foo: "some updated foo", bar: "some updated bar"}
  @invalid_attrs %{foo: nil, bar: nil}
  defp create_portfolio(_) do
    portfolio = portfolio_fixture()

    %{portfolio: portfolio}
  end

  describe "Index" do
    setup [:create_portfolio]

    test "lists all trades", %{conn: conn, portfolio: portfolio} do
      {:ok, _index_live, html} = live(conn, ~p"/trades")

      assert html =~ "Listing Trades"
      assert html =~ portfolio.foo
    end

    test "saves new portfolio", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/trades")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Portfolio")
               |> render_click()
               |> follow_redirect(conn, ~p"/trades/new")

      assert render(form_live) =~ "New Portfolio"

      assert form_live
             |> form("#portfolio-form", portfolio: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#portfolio-form", portfolio: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/trades")

      html = render(index_live)
      assert html =~ "Portfolio created successfully"
      assert html =~ "some foo"
    end

    test "updates portfolio in listing", %{conn: conn, portfolio: portfolio} do
      {:ok, index_live, _html} = live(conn, ~p"/trades")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#trades-#{portfolio.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/trades/#{portfolio}/edit")

      assert render(form_live) =~ "Edit Portfolio"

      assert form_live
             |> form("#portfolio-form", portfolio: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#portfolio-form", portfolio: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/trades")

      html = render(index_live)
      assert html =~ "Portfolio updated successfully"
      assert html =~ "some updated foo"
    end

    test "deletes portfolio in listing", %{conn: conn, portfolio: portfolio} do
      {:ok, index_live, _html} = live(conn, ~p"/trades")

      assert index_live |> element("#trades-#{portfolio.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#trades-#{portfolio.id}")
    end
  end

  describe "Show" do
    setup [:create_portfolio]

    test "displays portfolio", %{conn: conn, portfolio: portfolio} do
      {:ok, _show_live, html} = live(conn, ~p"/trades/#{portfolio}")

      assert html =~ "Show Portfolio"
      assert html =~ portfolio.foo
    end

    test "updates portfolio and returns to show", %{conn: conn, portfolio: portfolio} do
      {:ok, show_live, _html} = live(conn, ~p"/trades/#{portfolio}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/trades/#{portfolio}/edit?return_to=show")

      assert render(form_live) =~ "Edit Portfolio"

      assert form_live
             |> form("#portfolio-form", portfolio: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#portfolio-form", portfolio: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/trades/#{portfolio}")

      html = render(show_live)
      assert html =~ "Portfolio updated successfully"
      assert html =~ "some updated foo"
    end
  end
end
