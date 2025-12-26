defmodule Crypo.Prices.Price do
  use Ecto.Schema
  import Ecto.Changeset

  schema "prices" do
    field :symbol, :string
    field :price, :float

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(price, attrs) do
    price
    |> cast(attrs, [:symbol, :price])
    |> validate_required([:symbol, :price])
  end
end
