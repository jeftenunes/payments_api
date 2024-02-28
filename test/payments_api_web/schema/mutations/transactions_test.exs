defmodule PaymentsApiWeb.Schema.Mutations.TransactionsTest do
  use PaymentsApiWeb.DataCase

  alias PaymentsApi.{PaymentsFixtures, PaymentsHelpers}

  import Mox

  setup [:set_mox_global]

  @send_money_doc """
    mutation SendMoney($amount: String!, $description: String, $recipient: ID!, $source: ID!) {
      sendMoney(amount: $amount, description: $description, recipient: $recipient, source: $source) {
        amount,
        status,
        source,
        recipient,
        toCurrency,
        description,
        fromCurrency
      }
    }
  """

  describe "@sendMoney" do
    test "should send money from one wallet to another - different currencies" do
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
            PaymentsHelpers.mock_exchange_rate_by_currency({to_currency, from_currency}),
          from_currency: to_string(from_currency),
          last_refreshed: DateTime.now!("Etc/UTC")
        }
      end)

      user1 = PaymentsFixtures.user_fixture(%{email: "usr1@test.com"})

      wallet1 =
        PaymentsFixtures.wallet_fixture(%{user_id: to_string(user1.id), currency: "CAD"})

      user2 = PaymentsFixtures.user_fixture(%{email: "usr2@test.com"})

      wallet2 =
        PaymentsFixtures.wallet_fixture(%{user_id: to_string(user2.id), currency: "USD"})

      Process.sleep(5000)

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

      assert data["sendMoney"]["amount"] == "24000"
      assert data["sendMoney"]["status"] == "PENDING"
      assert data["sendMoney"]["toCurrency"] == "USD"
      assert data["sendMoney"]["fromCurrency"] == "CAD"
      assert data["sendMoney"]["description"] == "test transaction"
    end

    test "should send money from one wallet to another - same currencies" do
      # arrange
      stub(MockAlphaVantageApiWrapper, :fetch, fn %{
                                                    to_currency: _to_currency,
                                                    from_currency: _from_currency
                                                  } = _params ->
        {:error,
         %{
           CAD: [
             error: "error retrieving exchange rate",
             error: "error retrieving exchange rate"
           ],
           BRL: [
             error: "error retrieving exchange rate",
             error: "error retrieving exchange rate"
           ],
           USD: [
             error: "error retrieving exchange rate",
             error: "error retrieving exchange rate"
           ]
         }}
      end)

      user1 = PaymentsFixtures.user_fixture(%{email: "usr1@test.com"})

      wallet1 =
        PaymentsFixtures.wallet_fixture(%{user_id: to_string(user1.id), currency: "BRL"})

      user2 = PaymentsFixtures.user_fixture(%{email: "usr2@test.com"})

      wallet2 =
        PaymentsFixtures.wallet_fixture(%{user_id: to_string(user2.id), currency: "BRL"})

      Process.sleep(5000)

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

      assert data["sendMoney"]["amount"] == "20000"
      assert data["sendMoney"]["status"] == "PENDING"
      assert data["sendMoney"]["toCurrency"] == "BRL"
      assert data["sendMoney"]["fromCurrency"] == "BRL"
      assert data["sendMoney"]["description"] == "test transaction"
    end

    test "should not send money from one wallet to another - different currencies and alpha vantage api in error" do
      # arrange
      stub(MockAlphaVantageApiWrapper, :fetch, fn %{
                                                    to_currency: _to_currency,
                                                    from_currency: _from_currency
                                                  } = _params ->
        {:error,
         %{
           CAD: [
             error: "error retrieving exchange rate",
             error: "error retrieving exchange rate"
           ],
           BRL: [
             error: "error retrieving exchange rate",
             error: "error retrieving exchange rate"
           ],
           USD: [
             error: "error retrieving exchange rate",
             error: "error retrieving exchange rate"
           ]
         }}
      end)

      user1 = PaymentsFixtures.user_fixture(%{email: "usr1@test.com"})

      wallet1 =
        PaymentsFixtures.wallet_fixture(%{user_id: to_string(user1.id), currency: "CAD"})

      user2 = PaymentsFixtures.user_fixture(%{email: "usr2@test.com"})

      wallet2 =
        PaymentsFixtures.wallet_fixture(%{user_id: to_string(user2.id), currency: "USD"})

      Process.sleep(5000)

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

      assert List.first(errors)[:message] ==
               "Error retrieving exchange rates. You still can transfer money between same currency wallets."
    end

    test "should not send money from one wallet to another - invalid amount" do
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
            PaymentsHelpers.mock_exchange_rate_by_currency({to_currency, from_currency}),
          from_currency: to_string(from_currency),
          last_refreshed: DateTime.now!("Etc/UTC")
        }
      end)

      user1 = PaymentsFixtures.user_fixture(%{email: "usr1@test.com"})

      wallet1 =
        PaymentsFixtures.wallet_fixture(%{user_id: to_string(user1.id), currency: "CAD"})

      user2 = PaymentsFixtures.user_fixture(%{email: "usr2@test.com"})

      wallet2 =
        PaymentsFixtures.wallet_fixture(%{user_id: to_string(user2.id), currency: "USD"})

      Process.sleep(5000)

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

      assert List.first(errors)[:message] ==
               "cannot parse amount | abc"
    end
  end
end
