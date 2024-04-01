defmodule PaymentsApiWeb.Schema.Subscriptions.ExchangeRateTest do
  use PaymentsApiWeb.DataCase
  use PaymentsApiWeb.SubscriptionCase

  alias PaymentsApi.{PaymentsFixtures, PaymentsHelpers}

  import Mox

  setup [:set_mox_global]

  @exchange_rate_updated_for_currency_doc """
    subscription ExchangeRateUpdatedForCurrency($currency: String!){
      exchangeRateUpdatedForCurrency(currency: $currency) {
        exchangeRate, toCurrency, fromCurrency
      }
    }
  """

  @exchange_rate_updated_for_all_currencies_doc """
    subscription ExchangeRateUpdated {
      exchangeRatesUpdated {
        currency,
        exchangeRates {
          exchangeRate,
          toCurrency,
          fromCurrency
        }
      }
    }
  """

  describe "exchangeRateUpdatedForCurrency" do
    test "exchange rate updated for specific currency - USD", %{
      socket: socket
    } do
      # arrange

      stub(MockAlphaVantageApiClient, :fetch, fn %{
                                                   to_currency: to_currency,
                                                   from_currency: from_currency
                                                 } = _params ->
        %{
          bid_price: "1.50",
          ask_price: "2.10",
          to_currency: to_string(to_currency),
          exchange_rate:
            PaymentsHelpers.mock_exchange_rate_by_currency_with_variation(
              {to_currency, from_currency},
              3
            ),
          from_currency: to_string(from_currency),
          last_refreshed: DateTime.now!("Etc/UTC")
        }
      end)

      # act
      ref =
        push_doc(socket, @exchange_rate_updated_for_currency_doc,
          variables: %{
            "currency" => "USD"
          }
        )

      # assert
      assert_reply ref, :ok, %{subscriptionId: subscription_id}
      Process.sleep(5000)

      assert_push "subscription:data", data

      assert %{
        result: %{
          data: %{
            "exchangeRateUpdatedForCurrency" => [
              %{
                "exchangeRate" => "1.3",
                "fromCurrency" => "USD",
                "toCurrency" => "CAD"
              },
              %{
                "exchangeRate" => "4.7",
                "fromCurrency" => "USD",
                "toCurrency" => "BRL"
              }
            ]
          }
        }
      }
    end

    test "exchange rate updated for specific all currencies", %{
      socket: socket
    } do
      # arrange
      stub(MockAlphaVantageApiClient, :fetch, fn %{
                                                   to_currency: to_currency,
                                                   from_currency: from_currency
                                                 } = _params ->
        %{
          bid_price: "1.50",
          ask_price: "2.10",
          to_currency: to_string(to_currency),
          exchange_rate:
            PaymentsHelpers.mock_exchange_rate_by_currency_with_variation(
              {to_currency, from_currency},
              2
            ),
          from_currency: to_string(from_currency),
          last_refreshed: DateTime.now!("Etc/UTC")
        }
      end)

      # act
      ref =
        push_doc(socket, @exchange_rate_updated_for_all_currencies_doc, variables: %{})

      # assert
      assert_reply ref, :ok, %{subscriptionId: subscription_id}
      Process.sleep(5000)

      assert_push "subscription:data", data

      assert %{
               result: %{
                 data: %{
                   "exchangeRatesUpdated" => [
                     %{
                       "currency" => "CAD",
                       "exchangeRates" => [
                         %{
                           "exchangeRate" => "4.0",
                           "fromCurrency" => "CAD",
                           "toCurrency" => "BRL"
                         },
                         %{
                           "exchangeRate" => "1.0",
                           "fromCurrency" => "CAD",
                           "toCurrency" => "USD"
                         }
                       ]
                     },
                     %{
                       "currency" => "BRL",
                       "exchangeRates" => [
                         %{
                           "exchangeRate" => "0.30",
                           "fromCurrency" => "BRL",
                           "toCurrency" => "CAD"
                         },
                         %{
                           "exchangeRate" => "0.2",
                           "fromCurrency" => "BRL",
                           "toCurrency" => "USD"
                         }
                       ]
                     },
                     %{
                       "currency" => "USD",
                       "exchangeRates" => [
                         %{
                           "exchangeRate" => "1.2",
                           "fromCurrency" => "USD",
                           "toCurrency" => "CAD"
                         },
                         %{
                           "exchangeRate" => "4.2",
                           "fromCurrency" => "USD",
                           "toCurrency" => "BRL"
                         }
                       ]
                     }
                   ]
                 }
               },
               subscriptionId: ^subscription_id
             } = data
    end
  end
end
