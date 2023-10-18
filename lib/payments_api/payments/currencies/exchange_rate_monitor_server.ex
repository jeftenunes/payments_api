defmodule PaymentsApi.Payments.Currencies.ExchangeRateMonitorServer do
  use GenServer

  @default_name ExchangeRateMonitorServer

  @exchange_rate_cache_expiration Application.compile_env(
                                    :payments_api,
                                    :exchange_rate_cache_expiration
                                  )

  @exchange_rate_expiry_timeout :times.seconds(@exchange_rate_cache_expiration)

  def start_link(opts \\ []) do
    opts = Keyword.put_new(opts, :name, @default_name)
    Agent.start_link(fn -> %{} end, opts)
  end
end
