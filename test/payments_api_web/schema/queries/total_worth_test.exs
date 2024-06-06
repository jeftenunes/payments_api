defmodule PaymentsApiWeb.Schema.Queries.TotalWorthTest do
  use PaymentsApiWeb.DataCase

  alias PaymentsApi.{PaymentsFixtures, PaymentsHelpers}

  import Mox

  setup [:set_mox_global]

  @user_total_worth_doc """
    query UserTotalWorth ($userId: ID!, $currency: String!) {
      totalWorth(userId: $userId, currency: $currency) {
        userId, currency, totalWorth
      }
    }
  """

  @send_money_doc """
    mutation SendMoney($amount: String!, $description: String, $recipient: ID!, $source: ID!) {
      sendMoney(amount: $amount, description: $description, recipient: $recipient, source: $source) {
        amount,
        status,
        source,
        recipient,
        toCurrency,
        description,
        fromCurrency,
        exchangeRate
      }
    }
  """

  describe "totalWorth" do
    test "should retrieve user correct total worth after creating a wallet - no exchange rate applied" do
      usr = PaymentsFixtures.user_fixture(%{email: "total_worth_test@test.com"})

      PaymentsFixtures.wallet_fixture(%{user_id: to_string(usr.id), currency: "CAD"})

      # act
      assert {:ok, %{data: data}} =
               Absinthe.run(
                 @user_total_worth_doc,
                 PaymentsApiWeb.Schema,
                 variables: %{"userId" => usr.id, "currency" => "CAD"}
               )

      assert %{
               "totalWorth" => %{
                 "totalWorth" => "100.0"
               }
             } = data
    end

    test "should retrieve user correct total worth after creating a wallet - exchange rate applied" do
      # arrange

      stub(ExchangeRateStoreMock, :get_rate_for_currency, fn
        to_currency, from_currency ->
          %{
            exchange_rate:
              PaymentsHelpers.mock_exchange_rate_by_currency({to_currency, from_currency})
          }
      end)

      usr = PaymentsFixtures.user_fixture(%{email: "total_worth_test@test.com"})

      PaymentsFixtures.wallet_fixture(%{user_id: to_string(usr.id), currency: "CAD"})
      PaymentsFixtures.wallet_fixture(%{user_id: to_string(usr.id), currency: "BRL"})

      # act
      assert {:ok, %{data: data}} =
               Absinthe.run(
                 @user_total_worth_doc,
                 PaymentsApiWeb.Schema,
                 variables: %{"userId" => usr.id, "currency" => "USD"}
               )

      assert %{
               "totalWorth" => %{
                 "currency" => "USD",
                 "totalWorth" => "570.0"
               }
             } = data
    end

    test "should retrieve user correct total worth after processing a transaction - exchange rate applied" do
      # arrange
      stub(ExchangeRateStoreMock, :get_rate_for_currency, fn
        to_currency, from_currency ->
          %{
            exchange_rate:
              PaymentsHelpers.mock_exchange_rate_by_currency({to_currency, from_currency})
          }
      end)

      usr1 = PaymentsFixtures.user_fixture(%{email: "total_worth_test1@test.com"})

      wallet1 = PaymentsFixtures.wallet_fixture(%{user_id: to_string(usr1.id), currency: "CAD"})

      usr2 = PaymentsFixtures.user_fixture(%{email: "total_worth_test@test.com"})
      wallet2 = PaymentsFixtures.wallet_fixture(%{user_id: to_string(usr2.id), currency: "BRL"})

      assert {:ok, %{data: _data}} =
               Absinthe.run(
                 @send_money_doc,
                 PaymentsApiWeb.Schema,
                 variables: %{
                   "amount" => "25",
                   "source" => wallet2.id,
                   "recipient" => wallet1.id,
                   "description" => "test transaction"
                 }
               )

      # act
      assert {:ok, %{data: data}} =
               Absinthe.run(
                 @user_total_worth_doc,
                 PaymentsApiWeb.Schema,
                 variables: %{"userId" => usr1.id, "currency" => "CAD"}
               )

      assert %{
               "totalWorth" => %{
                 "currency" => "CAD",
                 "totalWorth" => "100.25"
               }
             } = data

      assert {:ok, %{data: data}} =
               Absinthe.run(
                 @user_total_worth_doc,
                 PaymentsApiWeb.Schema,
                 variables: %{"userId" => usr2.id, "currency" => "BRL"}
               )

      assert %{
               "totalWorth" => %{
                 "currency" => "BRL",
                 "totalWorth" => "99.75"
               }
             } = data
    end
  end
end
