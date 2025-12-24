defmodule Crypo.Repo do
  use Ecto.Repo,
    otp_app: :crypo,
    adapter: Ecto.Adapters.SQLite3
end
