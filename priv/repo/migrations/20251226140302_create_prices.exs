defmodule Crypo.Repo.Migrations.CreatePrices do
  use Ecto.Migration

  def change do
    create table(:prices) do
      add :symbol, :string, null: false
      add :price, :float, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create index(:prices, :symbol, unique: true)
  end
end
