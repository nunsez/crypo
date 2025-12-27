defmodule Crypo.Prices do
  @moduledoc """
  The Prices context.
  """

  import Ecto.Query, warn: false

  alias Crypo.Repo
  alias Crypo.Prices.Price

  require Logger

  @doc """
  Returns the list of prices.

  ## Examples

      iex> list_prices()
      [%Price{}, ...]

  """
  def list_prices do
    Repo.all(Price)
  end

  @doc """
  Gets a single price.

  Raises `Ecto.NoResultsError` if the Price does not exist.

  ## Examples

      iex> get_price!(123)
      %Price{}

      iex> get_price!(456)
      ** (Ecto.NoResultsError)

  """
  def get_price!(id), do: Repo.get!(Price, id)

  @doc """
  Creates a price.

  ## Examples

      iex> create_price(%{field: value})
      {:ok, %Price{}}

      iex> create_price(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_price(attrs) do
    %Price{}
    |> Price.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a price.

  ## Examples

      iex> update_price(price, %{field: new_value})
      {:ok, %Price{}}

      iex> update_price(price, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_price(%Price{} = price, attrs) do
    price
    |> Price.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a price.

  ## Examples

      iex> delete_price(price)
      {:ok, %Price{}}

      iex> delete_price(price)
      {:error, %Ecto.Changeset{}}

  """
  def delete_price(%Price{} = price) do
    Repo.delete(price)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking price changes.

  ## Examples

      iex> change_price(price)
      %Ecto.Changeset{data: %Price{}}

  """
  def change_price(%Price{} = price, attrs \\ %{}) do
    Price.changeset(price, attrs)
  end

  @spec sync_symbols(actual_symbols :: [String.t()]) :: :ok
  def sync_symbols(actual_symbols) do
    from(p in Price, where: p.symbol not in ^actual_symbols) |> Repo.delete_all()

    existing_symbols = from(p in Price, select: p.symbol) |> Repo.all()
    new_symbols = MapSet.difference(MapSet.new(actual_symbols), MapSet.new(existing_symbols))
    Logger.info("New symbols: #{new_symbols |> MapSet.to_list() |> inspect()}")

    Enum.each(new_symbols, fn symbol -> create_price(%{symbol: symbol, price: 0}) end)
  end
end
