defmodule PaymentsApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      PaymentsApiWeb.Telemetry,
      # Start the Ecto repository
      PaymentsApi.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: PaymentsApi.PubSub},
      # Start Finch
      {Finch, name: PaymentsApi.Finch},
      # Start the Endpoint (http/https)
      PaymentsApiWeb.Endpoint,
      PaymentsApi.UserTotalWorth.Store,
      {Absinthe.Subscription, PaymentsApiWeb.Endpoint},
      PaymentsApi.Payments.PaymentProcessingServer,
      PaymentsApi.Payments.Currencies.ExchangeRateMonitorServer
      # Start a worker by calling: PaymentsApi.Worker.start_link(arg)
      # {PaymentsApi.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PaymentsApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PaymentsApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
