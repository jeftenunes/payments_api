defmodule PaymentsApi.Payments.ExchangeRate do
  alias PaymentsApi.Payments.Parsers.MoneyParser
  alias PaymentsApi.Payments.Currencies.ExchangeRateMonitorServer

  def parse_exchange_rate(exchange_rate) do
    exchange_rate |> String.to_float()
  end

  def parse_exchange_rate_to_db(exchange_rate) do
    MoneyParser.maybe_parse_amount_from_string(exchange_rate)
  end

  def retrieve_exchange_rate(from_currency, to_currency) do
    do_retrieve_exchange_rate(from_currency, to_currency)
  end

  defp do_retrieve_exchange_rate(from_currency, to_currency) do
    case ExchangeRateMonitorServer.get_rate_for_currency(from_currency, to_currency) do
      {:error, reason} ->
        {:error, reason}

      exchange_rate ->
        exchange_rate.exchange_rate
    end
  end
end
