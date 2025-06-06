defmodule ProductApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ProductApiWeb.Telemetry,
      ProductApi.Repo,
      {DNSCluster, query: Application.get_env(:product_api, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ProductApi.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ProductApi.Finch},
      # Start cache processes with unique IDs
      Supervisor.child_spec({Cachex, name: :currency_cache, limit: 100}, id: :currency_cache),
      Supervisor.child_spec({Cachex, name: :products_cache, limit: 1000}, id: :products_cache),
      # Start a worker by calling: ProductApi.Worker.start_link(arg)
      # {ProductApi.Worker, arg},
      # Start to serve requests, typically the last entry
      ProductApiWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ProductApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ProductApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end