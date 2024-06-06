defmodule PaymentsApiWeb.Schema.Subscriptions.UserTotalWorthTest do
  use PaymentsApiWeb.DataCase
  use PaymentsApiWeb.SubscriptionCase

  alias PaymentsApi.{PaymentsFixtures, PaymentsHelpers}

  import Mox

  setup [:set_mox_global]

  @send_money_doc """
    mutation SendMoney($amount: String!, $description: String, $recipient: ID!, $source: ID!) {
      sendMoney(amount: $amount, description: $description, recipient: $recipient, source: $source) {
        id,
        amount,
        toCurrency,
        description,
        fromCurrency,
        exchangeRate
      }
    }
  """

  @user_total_worth_updated """
    subscription UserTotalWorthUpdated($id: ID!){
      userTotalWorthUpdated(id: $id) {
        userId,
        currency,
        totalWorth
      }
    }
  """

  describe "userTotalWorthUpdated" do
    test "should send a userTotalWorthUpdated message when an user sends a transfer", %{
      socket: socket
    } do
      # arrange
      stub(ExchangeRateStoreMock, :get_rate_for_currency, fn
        to_currency, from_currency ->
          %{
            exchange_rate:
              PaymentsHelpers.mock_exchange_rate_by_currency({to_currency, from_currency})
          }
      end)

      user1 = PaymentsFixtures.user_fixture(%{email: "usr1@test.com"})

      wallet1 =
        PaymentsFixtures.wallet_fixture(%{user_id: to_string(user1.id), currency: "CAD"})

      user2 = PaymentsFixtures.user_fixture(%{email: "usr2@test.com"})

      wallet2 =
        PaymentsFixtures.wallet_fixture(%{user_id: to_string(user2.id), currency: "USD"})

      # act
      ref =
        push_doc(socket, @user_total_worth_updated,
          variables: %{
            "id" => user2.id
          }
        )

      assert_reply ref, :ok, %{subscriptionId: subscription_id}

      ref =
        push_doc(socket, @send_money_doc,
          variables: %{
            "amount" => "50",
            "source" => wallet2.id,
            "recipient" => wallet1.id,
            "description" => "test transaction"
          }
        )

      # assert
      assert_reply ref, :ok, reply

      assert %{
               data: %{
                 "sendMoney" => %{
                   "amount" => "0.4",
                   "description" => "test transaction",
                   "exchangeRate" => "0.8",
                   "fromCurrency" => "USD",
                   "toCurrency" => "CAD"
                 }
               }
             } = reply

      usr1_id = to_string(user1.id)
      assert_push "subscription:data", data

      assert %{
               result: %{
                 data: %{
                   "userTotalWorthUpdated" => [
                     %{"currency" => "CAD", "totalWorth" => "79.6", "userId" => usr1_id},
                     %{"currency" => "BRL", "totalWorth" => "21.89", "userId" => usr1_id},
                     %{"currency" => "USD", "totalWorth" => "99.5", "userId" => usr1_id}
                   ]
                 }
               },
               subscriptionId: ^subscription_id
             } = data
    end

    test "should send a userTotalWorthUpdated message when an user receives a transfer", %{
      socket: socket
    } do
      # arrange
      stub(ExchangeRateStoreMock, :get_rate_for_currency, fn
        to_currency, from_currency ->
          %{
            exchange_rate:
              PaymentsHelpers.mock_exchange_rate_by_currency({to_currency, from_currency})
          }
      end)

      user1 = PaymentsFixtures.user_fixture(%{email: "usr1@test.com"})

      wallet1 =
        PaymentsFixtures.wallet_fixture(%{user_id: to_string(user1.id), currency: "CAD"})

      user2 = PaymentsFixtures.user_fixture(%{email: "usr2@test.com"})

      wallet2 =
        PaymentsFixtures.wallet_fixture(%{user_id: to_string(user2.id), currency: "USD"})

      # act
      ref =
        push_doc(socket, @user_total_worth_updated,
          variables: %{
            "id" => user2.id
          }
        )

      assert_reply ref, :ok, %{subscriptionId: subscription_id}

      ref =
        push_doc(socket, @send_money_doc,
          variables: %{
            "amount" => "5000",
            "source" => wallet2.id,
            "recipient" => wallet1.id,
            "description" => "test transaction"
          }
        )

      # assert
      assert_reply ref, :ok, reply

      assert %{
               data: %{
                 "sendMoney" => %{
                   "amount" => "40.0",
                   "description" => "test transaction",
                   "fromCurrency" => "USD",
                   "toCurrency" => "CAD"
                 }
               }
             } = reply

      usr2_id = to_string(user2.id)
      assert_push "subscription:data", data

      assert %{
               result: %{
                 data: %{
                   "userTotalWorthUpdated" => [
                     %{"currency" => "CAD", "totalWorth" => "40.0", "userId" => usr1_id},
                     %{"currency" => "BRL", "totalWorth" => "11.0", "userId" => usr1_id},
                     %{"currency" => "USD", "totalWorth" => "50.0", "userId" => usr1_id}
                   ]
                 }
               },
               subscriptionId: ^subscription_id
             } = data
    end
  end
end
