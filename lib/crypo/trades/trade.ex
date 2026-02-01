defmodule Crypo.Trades.Trade do
  use Ecto.Schema
  import Ecto.Changeset

  schema "trades" do
    field :exchange_id, :string
    field :order_id, :string
    field :trade_id, :string
    field :symbol, :string
    field :side, :string
    field :cash_flow, :float
    field :change, :float
    field :price, :float
    field :fee, :float
    field :fee_rate, :float
    field :transaction_time, :utc_datetime_usec
    field :disabled_at, :integer

    timestamps(type: :utc_datetime_usec)
  end

  @type t() :: %__MODULE__{}

  @required [
    :exchange_id,
    :order_id,
    :trade_id,
    :symbol,
    :side,
    :cash_flow,
    :change,
    :price,
    :fee,
    :fee_rate,
    :transaction_time
  ]

  @optional [:disabled_at]

  def disabled?(%__MODULE__{disabled_at: nil}), do: false
  def disabled?(%__MODULE__{}), do: true

  def enabled?(%__MODULE__{} = trade), do: not disabled?(trade)

  @doc false
  def changeset(trade, attrs) do
    trade
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
  end
end
