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

          <.link :if={!@symbol} class="link link-primary" patch={~p"/trades/#{trade.symbol}"}>
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

      socket = assign(socket, :page_title, "Listing #{symbol} Trades")
      socket = assign(socket, :header, "Listing #{symbol} Trades")
      socket = assign(socket, :symbol, true)
      socket = stream(socket, :trades, trades)

      {:ok, socket}
    else
      socket = redirect(socket, to: ~p"/trades/#{upcased}")
      {:ok, socket}
    end
  end

  def mount(_params, _session, socket) do
    trades = Trades.list_trades()

    socket = assign(socket, :page_title, "Listing Trades")
    socket = assign(socket, :header, "Listing Trades")
    socket = assign(socket, :symbol, false)
    socket = stream(socket, :trades, trades)

    {:ok, socket}
  end

  @impl true
  def handle_event("disable", %{"id" => id}, socket) do
    trade = Trades.get_trade!(id)

    case Trades.disable(trade) do
      {:ok, trade} ->
        socket = stream_insert(socket, :trades, trade)
        socket = put_flash(socket, :info, "Disabled")
        {:noreply, stream_insert(socket, :trades, trade)}

      {:error, %Ecto.Changeset{} = _changeset} ->
        socket = put_flash(socket, :error, "Disable error")
        {:noreply, socket}
    end
  end

  def handle_event("enable", %{"id" => id}, socket) do
    trade = Trades.get_trade!(id)

    case Trades.enable(trade) do
      {:ok, trade} ->
        socket = stream_insert(socket, :trades, trade)
        socket = put_flash(socket, :info, "Enabled")
        {:noreply, stream_insert(socket, :trades, trade)}

      {:error, %Ecto.Changeset{} = _changeset} ->
        socket = put_flash(socket, :error, "Enable error")
        {:noreply, socket}
    end
  end
end
