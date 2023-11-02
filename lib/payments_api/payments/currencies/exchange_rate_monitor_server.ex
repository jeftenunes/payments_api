defmodule PaymentsApi.Payments.Currencies.ExchangeRateMonitorServer do
  use GenServer

  alias PaymentsApi.Payments.Currencies.Currency

  @default_name ExchangeRateMonitorServer

  @exchange_rate_cache_expiration_in_ms Application.compile_env(
                                          :payments_api,
                                          :exchange_rate_cache_expiration_in_seconds
                                        ) * 1000

  @supported_currencies Application.compile_env(:payments_api, :supported_currencies)

  @type exchange_rate() :: %{
          ask_price: Integer.t(),
          bid_price: Integer.t(),
          to_currency: String.t(),
          from_currency: String.t(),
          exchange_rate: Integer.t(),
          last_refreshed: DateTime.t()
        }

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, %{}, name: @default_name)
  end

  defp fetch_rate_for_currency(from_currency, to_currencies) do
    ratings_for_currency =
      to_currencies
      |> Enum.map(&Currency.fetch_exchange_rate_from_api(from_currency, &1))

    {from_currency, ratings_for_currency}
  end

  ## server callbacks

  @impl true
  def init(state) do
    {:ok, state, {:continue, :start}}
  end

  @impl true
  def handle_continue(:start, state) do
    :timer.send_interval(
      @exchange_rate_cache_expiration_in_ms,
      :retrieve_exchange_rates
    )

    {:noreply, state}
  end

  @impl true
  def handle_info(:retrieve_exchange_rates, state) do
    exchange_rates =
      Enum.map(@supported_currencies, fn currency ->
        currencies_to_compare = Enum.filter(@supported_currencies, &(&1 != currency))
        fetch_rate_for_currency(currency, currencies_to_compare)
      end)
      |> Enum.into(%{})

    state = Map.put(state, :exchange_rates, exchange_rates)

    # IO.inspect(exchange_rates)

    {:noreply, state}
  end

  @impl true
  def handle_call({:get_rate_for_currency, currency}, _from, state) do
    rate_for_currency =
      Map.get(state, :exchange_rates)
      |> Map.get(currency)

    {:reply, rate_for_currency, state}
  end
end
