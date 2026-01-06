defmodule Crypo.Repo.Migrations.CreateSettings do
  use Ecto.Migration

  def change do
    create table(:settings, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:value, :string)
    end
  end
end
