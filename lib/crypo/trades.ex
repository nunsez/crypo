defmodule Crypo.Trades do
  @moduledoc """
  The Trades context.
  """

  import Ecto.Query, warn: false
  alias Crypo.Repo

  alias Crypo.Trades.Trade

  @doc """
  Returns the list of trades.

  ## Examples

      iex> list_trades()
      [%Trade{}, ...]

  """
  def list_trades do
    query = default_order(Trade)
    Repo.all(query)
  end

  def list_enabled_trades do
    query = from(t in Trade, where: is_nil(t.disabled_at))
    query = default_order(query)
    Repo.all(query)
  end

  @doc """
  Gets a single trade.

  Raises `Ecto.NoResultsError` if the Trade does not exist.

  ## Examples

      iex> get_trade!(123)
      %Trade{}

      iex> get_trade!(456)
      ** (Ecto.NoResultsError)

  """
  def get_trade!(id), do: Repo.get!(Trade, id)

  @doc """
  Creates a trade.

  ## Examples

      iex> create_trade(%{field: value})
      {:ok, %Trade{}}

      iex> create_trade(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_trade(attrs) do
    %Trade{}
    |> Trade.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a trade.

  ## Examples

      iex> update_trade(trade, %{field: new_value})
      {:ok, %Trade{}}

      iex> update_trade(trade, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_trade(%Trade{} = trade, attrs) do
    trade
    |> Trade.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a trade.

  ## Examples

      iex> delete_trade(trade)
      {:ok, %Trade{}}

      iex> delete_trade(trade)
      {:error, %Ecto.Changeset{}}

  """
  def delete_trade(%Trade{} = trade) do
    Repo.delete(trade)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking trade changes.

  ## Examples

      iex> change_trade(trade)
      %Ecto.Changeset{data: %Trade{}}

  """
  def change_trade(%Trade{} = trade, attrs \\ %{}) do
    Trade.changeset(trade, attrs)
  end

  def default_order(query) do
    order_by(query, desc: :transaction_time)
  end

  @spec last_trade_time() :: DateTime.t() | nil
  def last_trade_time do
    query = from(t in Trade, select: t.transaction_time, limit: 1)
    query = default_order(query)
    Repo.one(query)
  end

  @spec symbols() :: [String.t()]
  def symbols do
    query =
      from t in Trade,
        select: t.symbol,
        distinct: true

    Repo.all(query)
  end

  def find_by_symbol(symbol) do
    query = from(Trade, where: [symbol: ^symbol])
    query = default_order(query)
    Repo.all(query)
  end

  def disable(%Trade{} = trade) do
    now = System.system_time(:second)
    update_trade(trade, %{disabled_at: now})
  end

  def enable(%Trade{} = trade) do
    update_trade(trade, %{disabled_at: nil})
  end
end
