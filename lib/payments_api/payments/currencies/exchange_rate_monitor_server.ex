defmodule PaymentsApi.Payments.Currencies.ExchangeRateMonitorServer do
  use GenServer

  alias PaymentsApi.Payments.Currencies.ExchangeRatePollingTask
  alias PaymentsApi.Payments.Currencies

  @default_name ExchangeRateMonitorServer

  @type exchange_rate() :: %{
          ask_price: Integer.t(),
          bid_price: Integer.t(),
          to_currency: String.t(),
          from_currency: String.t(),
          exchange_rate: Integer.t(),
          last_refreshed: DateTime.t()
        }

  defstruct exchange_rates: nil

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, %{}, name: @default_name)
  end

  def get_rate_for_currency(from_currency, to_currency) do
    GenServer.call(@default_name, {:get_exchange_rate, from_currency, to_currency})
  end

  def update_exchange_rates(exchange_rates) do
    GenServer.cast(@default_name, {:update_exchange_rates, exchange_rates})
  end

  ## server callbacks

  @impl true
  def init(state) do
    {:ok, state, {:continue, :start}}
  end

  @impl true
  def handle_continue(:start, state) do
    ExchangeRatePollingTask.start_link()

    {:noreply, state}
  end

  @impl true
  def handle_call(
        {:get_exchange_rate, from_currency, to_currency},
        _from,
        state
      ) do
    exchange_rate =
      Map.get(state, :exchange_rates)[Currencies.get_currency_atom(from_currency)]
      |> Enum.filter(fn currency_rate -> filter_exchange_rates(currency_rate, to_currency) end)
      |> List.first()

    {:reply, exchange_rate, state}
  end

  @impl true
  def handle_cast({:publish_exchange_rates_updates, updated_exchange_rates}, state) do
    Enum.each(updated_exchange_rates, fn {currency, updated_exchange_rate} ->
      Absinthe.Subscription.publish(
        PaymentsApiWeb.Endpoint,
        updated_exchange_rate,
        exchange_rate_updated_for_currency: "exchange_rate_updated:#{currency}"
      )
    end)

    Absinthe.Subscription.publish(
      PaymentsApiWeb.Endpoint,
      Enum.map(updated_exchange_rates, fn {currency, exchange_rates} ->
        %{currency: currency, exchange_rates: exchange_rates}
      end),
      exchange_rates_updated: "exchange_rates_updated"
    )

    {:noreply, state}
  end

  @impl true
  def handle_cast({:update_exchange_rates, exchange_rates}, state) do
    exchange_rates = Enum.into(exchange_rates, %{})

    updated_exchange_rates =
      retrieve_updated_exchange_rates(state[:exchange_rates], exchange_rates)

    GenServer.cast(self(), {:publish_exchange_rates_updates, updated_exchange_rates})

    state =
      Map.put(
        state,
        :exchange_rates,
        exchange_rates
      )

    {:noreply, state}
  end

  ## helpers
  defp filter_exchange_rates({:error, message}, _to_currency), do: {:error, message}

  defp filter_exchange_rates(currency_rate, to_currency),
    do: currency_rate.to_currency === to_currency

  defp retrieve_updated_exchange_rates(nil, new_rates) do
    new_rates
  end

  defp retrieve_updated_exchange_rates(actual_rates, new_rates) do
    Enum.filter(new_rates, fn {k, v} ->
      actual_rate = Map.get(actual_rates, k)

      actual_rate !== v
    end)
  end
end
