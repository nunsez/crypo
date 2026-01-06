defmodule Crypo.Settings do
  @moduledoc """
  The Settings context.
  """

  import Ecto.Query, warn: false

  alias Crypo.Repo
  alias Crypo.Settings.Setting

  @trades_imported_at "trades_imported_at"

  @spec trades_imported_at() :: DateTime.t() | nil
  def trades_imported_at do
    with %Setting{value: value} <- Repo.get(Setting, @trades_imported_at),
         {integer, ""} <- Integer.parse(value, 10),
         {:ok, datetime} <- DateTime.from_unix(integer, :millisecond) do
      datetime
    else
      _any -> nil
    end
  end

  @spec set_trades_imported_at(value :: non_neg_integer() | DateTime.t()) ::
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def set_trades_imported_at(value) when is_integer(value) do
    value = Integer.to_string(value)

    %Setting{id: @trades_imported_at, value: value}
    |> Repo.insert(on_conflict: {:replace, [:value]})
  end

  def set_trades_imported_at(%DateTime{} = value) do
    value
    |> DateTime.to_unix(:millisecond)
    |> set_trades_imported_at()
  end
end
