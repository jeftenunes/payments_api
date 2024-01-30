defmodule PaymentsApi.Payments.Currencies.ExchangeRateMonitorServer do
  use GenServer

  alias PaymentsApi.Payments.Currencies

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

  defstruct supervisor: nil, exchange_rates: nil

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, %{}, name: @default_name)
  end

  def get_rate_for_currency(from_currency, to_currency) do
    GenServer.call(@default_name, {:get_exchange_rate, from_currency, to_currency})
  end

  ## server callbacks

  @impl true
  def init(state) do
    {:ok, supervisor} = Task.Supervisor.start_link()

    state = Map.put(state, :supervisor, supervisor)

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
  def handle_info(
        :retrieve_exchange_rates,
        %{supervisor: _supervisor} = state
      ) do
    exchange_rates =
      Enum.map(@supported_currencies, fn currency ->
        currencies_to_compare = Enum.filter(@supported_currencies, &(&1 != currency))
        fetch_rate_for_currency(currency, currencies_to_compare)
      end)
      |> Enum.into(%{})

    Map.get(state, :exchange_rates)
    |> retrieve_updated_exchange_rates(exchange_rates)
    |> publish_exchange_rates_updates(state)

    state =
      Map.put(
        state,
        :exchange_rates,
        exchange_rates
      )

    {:noreply, state}
  end

  @impl true
  def handle_call(
        {:get_exchange_rate, from_currency, to_currency},
        _from,
        %{supervisor: _supervisor} = state
      ) do
    exchange_rate =
      Map.get(state, :exchange_rates)[Currencies.get_currency_atom(from_currency)]
      |> Enum.filter(fn currency_rate -> currency_rate.to_currency == to_currency end)
      |> List.first()

    {:reply, exchange_rate, state}
  end

  ## helpers
  defp publish_exchange_rates_updates(updated_exchange_rates, %{supervisor: supervisor} = _state) do
    Enum.each(updated_exchange_rates, fn {currency, updated_exchange_rate} ->
      Task.Supervisor.start_child(supervisor, fn ->
        Absinthe.Subscription.publish(
          PaymentsApiWeb.Endpoint,
          updated_exchange_rate,
          exchange_rate_updated_for_currency: "exchange_rate_updated:#{currency}"
        )
      end)
    end)

    Task.Supervisor.start_child(supervisor, fn ->
      Absinthe.Subscription.publish(
        PaymentsApiWeb.Endpoint,
        Enum.map(updated_exchange_rates, fn {currency, exchange_rates} ->
          %{currency: currency, exchange_rates: exchange_rates}
        end),
        exchange_rates_updated: "exchange_rates_updated"
      )
    end)
  end

  defp fetch_rate_for_currency(from_currency, to_currencies) do
    ratings_for_currency =
      to_currencies
      |> Enum.map(&Currencies.fetch_exchange_rate_from_api(from_currency, &1))

    {from_currency, ratings_for_currency}
  end

  defp retrieve_updated_exchange_rates(nil, new_rates) do
    new_rates
  end

  defp retrieve_updated_exchange_rates(actual_rates, new_rates) do
    new_rates
    |> Enum.filter(fn {k, v} ->
      actual_rate = Map.get(actual_rates, k)

      actual_rate != v
    end)
  end
end
