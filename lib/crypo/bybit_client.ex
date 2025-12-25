defmodule Crypo.BybitClient do
  # 7 days
  @spec period_ms() :: pos_integer()
  def period_ms, do: 604_800_000

  @spec transaction_log_limit() :: pos_integer()
  def transaction_log_limit, do: 50

  def get_transaction_log(start_time, cursor) do
    params = %{
      "accountType" => "UNIFIED",
      "category" => "spot",
      "startTime" => start_time,
      "endTime" => start_time + period_ms(),
      "limit" => transaction_log_limit()
    }

    params = maybe_put_cursor(params, cursor)

    get_authenticated("/v5/account/transaction-log", params)
  end

  def maybe_put_cursor(params, nil), do: params
  def maybe_put_cursor(params, cursor), do: Map.put(params, "cursor", cursor)

  def client do
    headers = [x_bapi_api_key: api_key()]
    Req.new(base_url: api_rest(), headers: headers)
  end

  def post_authenticated(endpoint, params \\ %{}) do
    json = JSON.encode!(params)

    headers! = auth_headers(json)
    headers! = Keyword.merge(headers!, content_type: "application/json")

    req = Req.merge(client(), url: endpoint, body: json, headers: headers!)
    Req.post!(req)
  end

  def get_authenticated(endpoint, params \\ %{}) do
    query = URI.encode_query(params)
    headers = auth_headers(query)

    req = Req.merge(client(), url: endpoint, params: params, headers: headers)
    Req.get!(req)
  end

  def get_public(endpoint, params \\ %{}) do
    Req.get!(client(), url: endpoint, params: params)
  end

  def auth_headers(query) do
    timestamp = timestamp()
    recv_window = "5000"
    signature = generate_signature(timestamp, recv_window, query)

    [
      x_bapi_sign: signature,
      x_bapi_timestamp: timestamp,
      x_bapi_recv_window: recv_window
    ]
  end

  # timestamp+api_key+recv_window+queryString
  def generate_signature(timestamp, recv_window, query) do
    str = timestamp <> api_key() <> recv_window <> query
    hmac = :crypto.mac(:hmac, :sha256, secret(), str)
    Base.encode16(hmac, case: :lower)
  end

  def timestamp do
    DateTime.utc_now()
    |> DateTime.to_unix(:millisecond)
    |> Integer.to_string()
  end

  def api_key do
    Keyword.fetch!(config(), :api_key)
  end

  def secret do
    Keyword.fetch!(config(), :api_secret)
  end

  def api_rest do
    Keyword.fetch!(config(), :api_rest)
  end

  defp config do
    Application.fetch_env!(:crypo, :bybit)
  end
end
