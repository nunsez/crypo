defmodule Crypo.Repo.Migrations.CreateTrades do
  use Ecto.Migration

  def change do
    create table(:trades) do
      add :exchange_id, :string, null: false
      add :order_id, :string
      add :trade_id, :string
      add :symbol, :string, null: false
      add :side, :string, null: false
      add :cash_flow, :float, null: false
      add :change, :float
      add :price, :float, null: false
      add :fee, :float
      add :fee_rate, :float
      add :transaction_time, :utc_datetime_usec, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create index(:trades, :exchange_id, unique: true)
    create index(:trades, :symbol)
    create index(:trades, :side)
    create index(:trades, :transaction_time)
  end
end
