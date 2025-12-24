defmodule Crypo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CrypoWeb.Telemetry,
      Crypo.Repo,
      {Ecto.Migrator,
       repos: Application.fetch_env!(:crypo, :ecto_repos), skip: skip_migrations?()},
      {DNSCluster, query: Application.get_env(:crypo, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Crypo.PubSub},
      # Start a worker by calling: Crypo.Worker.start_link(arg)
      # {Crypo.Worker, arg},
      # Start to serve requests, typically the last entry
      CrypoWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Crypo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CrypoWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp skip_migrations?() do
    # By default, sqlite migrations are run when using a release
    System.get_env("RELEASE_NAME") == nil
  end
end
