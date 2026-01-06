defmodule Crypo.Settings.Setting do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id
  schema "settings" do
    field :value, :string
  end

  @type t() :: %__MODULE__{}

  @doc false
  def changeset(setting, attrs) do
    setting
    |> cast(attrs, [:value])
    |> validate_required([:value])
  end
end
