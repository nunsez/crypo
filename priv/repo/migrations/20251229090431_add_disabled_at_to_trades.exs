defmodule Crypo.Repo.Migrations.AddDisabledAtToTrades do
  use Ecto.Migration

  def change do
    alter table(:trades) do
      add(:disabled_at, :integer)
    end
  end
end
