defmodule PaymentsApiWeb.Schema.Subscriptions.ExchangeRateTest do
  use PaymentsApiWeb.DataCase
  use PaymentsApiWeb.SubscriptionCase

  alias PaymentsApi.{PaymentsFixtures, PaymentsHelpers}

  import Mox

  setup [:set_mox_global]

  @exchange_rate_update_doc """
  subscription exchangeRateUpdatedForCurrency($currency: String!){
    exchangeRateUpdatedForCurrency(currency: $currency) {
      exchangeRate, toCurrency, fromCurrency
    }
  }
  """

  describe "exchangeRateUpdatedForCurrency" do
    test "exchange rate updated for specific currency - 3 times", %{
      socket: socket
    } do
      # arrange
      stub(MockAlphaVantageApiWrapper, :fetch, fn %{
                                                    to_currency: to_currency,
                                                    from_currency: from_currency
                                                  } = _params ->
        %{
          bid_price: "1.50",
          ask_price: "2.10",
          to_currency: to_string(to_currency),
          exchange_rate:
            PaymentsHelpers.mock_exchange_rate_by_currency_with_variation(
              {to_currency, from_currency}
            ),
          from_currency: to_string(from_currency),
          last_refreshed: DateTime.now!("Etc/UTC")
        }
      end)

      Process.sleep(5000)

      # act
      ref =
        push_doc(socket, @exchange_rate_update_doc,
          variables: %{
            "currency" => "USD"
          }
        )

      assert_reply ref, :ok, %{subscriptionId: subscription_id}
      Process.sleep(5000)

      # assert
      assert_push "subscription:data", data
    end
  end
end
