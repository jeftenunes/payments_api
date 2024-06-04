defmodule PaymentsApi.Currencies.ExchangeRateStoreBehaviour do
  @callback get_rate_for_currency(String.t(), String.t()) :: map()
end
