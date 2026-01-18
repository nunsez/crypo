defmodule Crypo.Portfolio.Item do
  @enforce_keys [
    :id,
    :symbol,
    :currency,
    :balance,
    :buy_average,
    :my_cost,
    :current_price,
    :current_cost,
    :pl_dollars,
    :pl_percent,
    :share
  ]

  defstruct @enforce_keys

  @type t() :: %__MODULE__{
          id: String.t(),
          symbol: String.t(),
          currency: float(),
          balance: float(),
          buy_average: float(),
          my_cost: float(),
          current_price: float(),
          current_cost: float(),
          pl_dollars: float(),
          pl_percent: float(),
          share: float()
        }

  def compare(a, b, conditions, decision \\ false)
  def compare(_a, _b, [], decision), do: decision

  def compare(a, b, [{direction, field} | rest], _decision) do
    value_a = Map.get(a, field)
    value_b = Map.get(b, field)

    cond do
      value_a == value_b -> compare(a, b, rest, false)
      is_nil(value_a) or value_a < value_b -> direction == :asc
      is_nil(value_b) or value_a > value_b -> direction == :desc
    end
  end

  @spec share(item :: t(), portfolio_cost :: float()) :: float()
  def share(%__MODULE__{current_cost: current_cost}, portfolio_cost)
      when is_float(portfolio_cost) and portfolio_cost > 0 do
    Float.round(current_cost * 100 / portfolio_cost, 1)
  end

  def share(%__MODULE__{}, _portfolio_cost), do: 0.0
end
