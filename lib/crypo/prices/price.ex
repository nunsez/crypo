defmodule Crypo.Prices.Price do
  use Ecto.Schema
  import Ecto.Changeset

  schema "prices" do
    field :symbol, :string
    field :price, :float

    timestamps(type: :utc_datetime_usec)
  end

  @required [:symbol, :price]

  @doc false
  def changeset(price, attrs) do
    price
    |> cast(attrs, @required)
    |> validate_required(@required)
    |> unique_constraint(:symbol)
  end
end
