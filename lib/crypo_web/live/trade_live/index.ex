defmodule CrypoWeb.TradeLive.Index do
  use CrypoWeb, :live_view

  alias Crypo.Trades
  alias Crypo.Trades.Trade

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>Listing Trades</.header>

      <.table
        id="trades"
        rows={@streams.trades}
      >
        <:col :let={{_id, trade}} label="Symbol">{trade.symbol}</:col>
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
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Trades")
     |> stream(:trades, list_trades())}
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

  defp list_trades() do
    Trades.list_trades()
  end
end
