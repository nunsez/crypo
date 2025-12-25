defmodule Crypo.Trades.Import do
  alias Crypo.BybitClient
  alias Crypo.Trades
  alias Crypo.Trades.Trade
  alias Crypo.Repo

  require Logger

  def call do
    datetime = Trades.last_trade_time() || two_years_ago()
    timestamp = DateTime.to_unix(datetime, :millisecond)
    get_all_transactions(timestamp + 1, nil)
  end

  @spec two_years_ago() :: pos_integer()
  def two_years_ago do
    DateTime.utc_now(:millisecond)
    |> DateTime.add(-720, :day)
    |> DateTime.to_unix(:millisecond)
  end

  @spec import_trades(list :: [map()]) :: :ok
  def import_trades(list) do
    Enum.each(list, &import_trade/1)
  end

  @spec import_trade(data :: map()) :: :ok
  def import_trade(
        %{
          "category" => "spot",
          "type" => "TRADE",
          "currency" => currency,
          "side" => side
        } = data
      )
      when currency != "USDT" and side in ["Buy", "Sell"] do
    attrs = %{
      exchange_id: data["id"],
      order_id: data["orderId"],
      trade_id: data["tradeId"],
      symbol: data["symbol"],
      side: data["side"],
      cash_flow: parse_float!(data["cashFlow"]),
      change: parse_float!(data["change"]),
      price: parse_float!(data["tradePrice"]),
      fee: parse_float!(data["fee"]),
      fee_rate: parse_float!(data["feeRate"]),
      transaction_time: parse_datetime!(data["transactionTime"])
    }

    case insert_trade(attrs) do
      {:ok, _trade} ->
        :ok

      {:error, %Ecto.Changeset{} = changeset} ->
        errors = JSON.encode!(changeset.errors)
        Logger.error("import trade #{attrs[:exchange_id]} error: #{errors}")
        :error
    end
  end

  def import_trade(%{"category" => category, "type" => type, "currency" => currency}) do
    Logger.info("Skip data: #{category} | #{type} | #{currency}")
  end

  def insert_trade(attrs) do
    %Trade{}
    |> Trade.changeset(attrs)
    |> Repo.insert(on_conflict: :nothing)
  end

  def parse_float!(string) do
    {value, ""} = Float.parse(string)
    value
  end

  def parse_datetime!(string) do
    {value, ""} = Integer.parse(string, 10)
    DateTime.from_unix!(value, :millisecond)
  end

  @spec get_all_transactions(start_time :: pos_integer(), cursor :: String.t() | nil) ::
          {:ok, :done} | {:error, :too_early} | {:error, {pos_integer(), String.t()}}
  def get_all_transactions(start_time, cursor) do
    Logger.info("start_time: #{start_time}, current cursor: #{cursor}")

    response = BybitClient.get_transaction_log(start_time, cursor)

    case response.body do
      %{"retCode" => 10001} ->
        {:error, :too_early}

      %{"result" => %{"list" => list, "nextPageCursor" => next_cursor}} ->
        Logger.info("list len: #{length(list)}, next cursor: #{next_cursor}")
        import_trades(list)
        Process.sleep(:timer.seconds(1))

        case make_decision(start_time, next_cursor, list) do
          :done -> {:ok, :done}
          :continue_pagination -> get_all_transactions(start_time, next_cursor)
          {:advance_time_window, next_start_time} -> get_all_transactions(next_start_time, nil)
        end

      body ->
        Logger.error("""
        get_all_transactions error. status: #{response.status}.
        start_time: #{start_time}, cursor: #{cursor}
        body: #{inspect(body)}
        """)

        {:error, {start_time, cursor}}
    end
  end

  @spec make_decision(start_time :: pos_integer(), next_cursor :: String.t(), list :: [map()]) ::
          :continue_pagination | :done | {:advance_time_window, pos_integer()}
  def make_decision(start_time, next_cursor, list) do
    if not is_nil(next_cursor) and length(list) >= BybitClient.transaction_log_limit() do
      :continue_pagination
    else
      next_start_time = start_time + BybitClient.period_ms()
      current_time = System.system_time(:millisecond)

      if next_start_time >= current_time do
        :done
      else
        {:advance_time_window, next_start_time}
      end
    end
  end
end
