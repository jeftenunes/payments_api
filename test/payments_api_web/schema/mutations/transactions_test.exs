defmodule PaymentsApiWeb.Schema.Mutations.TransactionsTest do
  use PaymentsApiWeb.DataCase

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

  describe "@sendMoney" do
    test "should send money from one wallet to another - different currencies" do
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
      assert {:ok, %{data: data}} =
               Absinthe.run(
                 @send_money_doc,
                 PaymentsApiWeb.Schema,
                 variables: %{
                   "amount" => "2000",
                   "source" => wallet2.id,
                   "recipient" => wallet1.id,
                   "description" => "test transaction"
                 }
               )

      assert %{
               "sendMoney" => %{
                 "amount" => "16.0",
                 "description" => "test transaction",
                 "exchangeRate" => "0.8",
                 "fromCurrency" => "USD",
                 "toCurrency" => "CAD"
               }
             } = data
    end

    test "should send money from one wallet to another - same currencies" do
      # arrange

      stub(ExchangeRateStoreMock, :get_rate_for_currency, fn
        to_currency, from_currency -> {:error, "MESSAGE"}
      end)

      user1 = PaymentsFixtures.user_fixture(%{email: "usr1@test.com"})

      wallet1 =
        PaymentsFixtures.wallet_fixture(%{user_id: to_string(user1.id), currency: "BRL"})

      user2 = PaymentsFixtures.user_fixture(%{email: "usr2@test.com"})

      wallet2 =
        PaymentsFixtures.wallet_fixture(%{user_id: to_string(user2.id), currency: "BRL"})

      # act

      assert {:ok, %{data: data}} =
               Absinthe.run(
                 @send_money_doc,
                 PaymentsApiWeb.Schema,
                 variables: %{
                   "amount" => "200",
                   "source" => wallet2.id,
                   "recipient" => wallet1.id,
                   "description" => "test transaction"
                 }
               )

      assert %{
               "sendMoney" => %{
                 "amount" => "2.0",
                 "description" => "test transaction",
                 "exchangeRate" => "1.0",
                 "fromCurrency" => "BRL",
                 "toCurrency" => "BRL"
               }
             } = data
    end

    test "should not send money from one wallet to another - different currencies and alpha vantage api in error" do
      # arrange
      stub(ExchangeRateStoreMock, :get_rate_for_currency, fn
        to_currency, from_currency ->
          {:error,
           "Error retrieving exchange rates. You still can transfer money between same currency wallets."}
      end)

      user1 = PaymentsFixtures.user_fixture(%{email: "usr1@test.com"})

      wallet1 =
        PaymentsFixtures.wallet_fixture(%{user_id: to_string(user1.id), currency: "CAD"})

      user2 = PaymentsFixtures.user_fixture(%{email: "usr2@test.com"})

      wallet2 =
        PaymentsFixtures.wallet_fixture(%{user_id: to_string(user2.id), currency: "USD"})

      # act
      assert {:ok, %{data: _data, errors: errors}} =
               Absinthe.run(
                 @send_money_doc,
                 PaymentsApiWeb.Schema,
                 variables: %{
                   "amount" => "200",
                   "source" => wallet2.id,
                   "recipient" => wallet1.id,
                   "description" => "test transaction"
                 }
               )

      assert [
               %{
                 message:
                   "Error retrieving exchange rates. You still can transfer money between same currency wallets."
               }
             ] = errors
    end

    test "should not send money from one wallet to another - invalid amount" do
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

      # Process.sleep(5000)

      # act
      assert {:ok, %{data: _data, errors: errors}} =
               Absinthe.run(
                 @send_money_doc,
                 PaymentsApiWeb.Schema,
                 variables: %{
                   "amount" => "abc",
                   "source" => wallet2.id,
                   "recipient" => wallet1.id,
                   "description" => "test transaction"
                 }
               )

      assert [%{message: "invalid amount"}] = errors
    end
  end
end
