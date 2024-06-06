defmodule PaymentsApi.Currencies.ExchangeRatePollingTask do
  use Task

  alias PaymentsApi.Currencies.ExchangeRateStore
  alias PaymentsApi.Currencies.AlphaVantageApiClient

  @exchange_rate_cache_expiration_in_ms Application.compile_env(
                                          :payments_api,
                                          :exchange_rate_cache_expiration_in_seconds
                                        ) * 1000

  @supported_currencies Application.compile_env(:payments_api, :supported_currencies)

  def start_link(_) do
    Task.start_link(fn ->
      schedule_exchange_rate_retrieval()
    end)
  end

  defp schedule_exchange_rate_retrieval do
    Process.sleep(@exchange_rate_cache_expiration_in_ms)
    retrieve_exchange_rates()
  end

  defp retrieve_exchange_rates do
    exchange_rates =
      Enum.map(@supported_currencies, fn currency ->
        currencies_to_compare = Enum.filter(@supported_currencies, &(&1 !== currency))
        fetch_rate_for_currency(currency, currencies_to_compare)
      end)

    exchange_rates = Enum.into(exchange_rates, %{})
    ExchangeRateStore.update_exchange_rate(exchange_rates)
    schedule_exchange_rate_retrieval()
  end

  defp fetch_rate_for_currency(from_currency, to_currencies) do
    ratings_for_currency =
      Enum.map(
        to_currencies,
        &api_client().fetch(%{from_currency: from_currency, to_currency: &1})
      )

    {from_currency, ratings_for_currency}
  end

  defp api_client,
    do: Application.get_env(:payments_api, :alpha_vantage_api_client, AlphaVantageApiClient)
end
