defmodule Crypo.PricesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Crypo.Prices` context.
  """

  @doc """
  Generate a price.
  """
  def price_fixture(attrs \\ %{}) do
    {:ok, price} =
      attrs
      |> Enum.into(%{
        price: 120.5,
        symbol: "some symbol"
      })
      |> Crypo.Prices.create_price()

    price
  end
end
