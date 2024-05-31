defmodule PaymentsApi.Currencies.ExchangeRateStoreStub do
  alias PaymentsApi.Currencies
  alias PaymentsApi.PaymentsHelpers

  def get_rate_for_currency(_agent_name \\ "", from_currency, to_currency) do
    %{
      bid_price: "1.50",
      ask_price: "2.10",
      to_currency: to_string(to_currency),
      exchange_rate:
        PaymentsHelpers.mock_exchange_rate_by_currency(
          {Currencies.get_currency_atom(to_currency), Currencies.get_currency_atom(from_currency)}
        ),
      from_currency: to_string(from_currency),
      last_refreshed: DateTime.now!("Etc/UTC")
    }
  end
end
