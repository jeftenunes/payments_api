defmodule PaymentsApi.Payments.ExchangeRate do
  alias PaymentsApi.Payments.Currencies.ExchangeRateMonitorServer

  def parse_exchange_rate(exchange_rate) do
    String.replace(exchange_rate, ".", "")
    |> String.to_integer()
  end

  def retrieve_exchange_rate(from_currency, to_currency) do
    ExchangeRateMonitorServer.get_rate_for_currency(from_currency, to_currency)
  end
end
