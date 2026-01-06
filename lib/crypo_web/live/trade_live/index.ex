defmodule CrypoWeb.TradeLive.Index do
  use CrypoWeb, :live_view

  alias Crypo.Trades
  alias Crypo.Trades.Trade

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>{@header}</.header>

      <.table
        id="trades"
        rows={@streams.trades}
      >
        <:col :let={{_id, trade}} label="Symbol">
          <span :if={@symbol}>{trade.symbol}</span>

          <.link :if={!@symbol} class="link link-primary" navigate={~p"/trades/#{trade.symbol}"}>
            {trade.symbol}
          </.link>
        </:col>

        <:col :let={{_id, trade}} label="Side">{trade.side}</:col>
        <:col :let={{_id, trade}} label="Change">{trade.change}</:col>
        <:col :let={{_id, trade}} label="Price">{trade.price}</:col>
        <:col :let={{_id, trade}} label="Transaction time">{trade.transaction_time}</:col>

        <:action :let={{_id, trade}}>
          <%= if Trade.disabled?(trade) do %>
            <.link class="link link-warning" phx-click={JS.push("enable", value: %{id: trade.id})}>
              Disabled
            </.link>
          <% else %>
            <.link class="link link-success" phx-click={JS.push("disable", value: %{id: trade.id})}>
              Enabled
            </.link>
          <% end %>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"symbol" => symbol}, _session, socket) do
    upcased = String.upcase(symbol)

    if symbol == upcased do
      trades = Trades.find_by_symbol(symbol)

      socket =
        socket
        |> assign(:page_title, "Listing #{symbol} Trades")
        |> assign(:header, "Listing #{symbol} Trades")
        |> assign(:symbol, symbol)
        |> stream(:trades, trades)

      {:ok, socket}
    else
      socket =
        socket
        |> redirect(to: ~p"/trades/#{upcased}")

      {:ok, socket}
    end
  end

  def mount(_params, _session, socket) do
    trades = Trades.list_trades()

    socket =
      socket
      |> assign(:page_title, "Listing Trades")
      |> assign(:header, "Listing Trades")
      |> assign(:symbol, nil)
      |> stream(:trades, trades)

    {:ok, socket}
  end

  @impl true
  def handle_event("disable", %{"id" => id}, socket) do
    trade = Trades.get_trade!(id)

    case Trades.disable(trade) do
      {:ok, trade} ->
        socket =
          socket
          |> stream_insert(:trades, trade)
          |> put_flash(:info, "Disabled")

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = _changeset} ->
        socket =
          socket
          |> put_flash(:error, "Disable error")

        {:noreply, socket}
    end
  end

  def handle_event("enable", %{"id" => id}, socket) do
    trade = Trades.get_trade!(id)

    case Trades.enable(trade) do
      {:ok, trade} ->
        socket =
          socket
          |> stream_insert(:trades, trade)
          |> put_flash(:info, "Enabled")

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = _changeset} ->
        socket =
          socket
          |> put_flash(:error, "Enable error")

        {:noreply, socket}
    end
  end

  def handle_event("update-prices", _unsigned_params, socket) do
    # ignore
    {:noreply, socket}
  end

  def handle_event("update-trades", _unsigned_params, socket) do
    Trades.Import.call()

    symbol = socket.assigns[:symbol]
    trades = if symbol, do: Trades.find_by_symbol(symbol), else: Trades.list_trades()

    socket =
      socket
      |> stream(:trades, trades)

    {:noreply, socket}
  end
end
