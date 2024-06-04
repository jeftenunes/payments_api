defmodule PaymentsApi.Currencies.ExchangeRateStore do
  @behaviour PaymentsApi.Currencies.ExchangeRateStoreBehaviour

  use Agent

  alias PaymentsApi.Currencies

  @default_name ExchangeRateStore

  def start_link(opts \\ []) do
    opts = Keyword.put_new(opts, :name, @default_name)
    Agent.start_link(fn -> %{exchange_rates: %{}} end, opts)
  end

  def get_rate_for_currency(from_currency, to_currency) do
    Agent.get(@default_name, fn state ->
      Map.get(state, :exchange_rates)[Currencies.get_currency_atom(from_currency)]
      |> Enum.filter(fn currency_rate -> filter_exchange_rates(currency_rate, to_currency) end)
      |> List.first()
    end)
  end

  def update_exchange_rate(agent \\ @default_name, exchange_rates) do
    Agent.update(agent, fn state ->
      updated_exchange_rates =
        retrieve_updated_exchange_rates(state[:exchange_rates], exchange_rates)

      publish_exchange_rates_updates(updated_exchange_rates)

      Map.put(state, :exchange_rates, exchange_rates)
    end)
  end

  defp retrieve_updated_exchange_rates(nil, new_rates) do
    new_rates
  end

  defp retrieve_updated_exchange_rates(actual_rates, new_rates) do
    Enum.filter(new_rates, fn {k, v} ->
      actual_rate = Map.get(actual_rates, k)

      actual_rate !== v
    end)
  end

  defp filter_exchange_rates({:error, message}, _to_currency), do: {:error, message}

  defp filter_exchange_rates(currency_rate, to_currency),
    do: currency_rate.to_currency === to_currency

  defp publish_exchange_rates_updates(updated_exchange_rates) do
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
  end
end
