defmodule PaymentsApiWeb.Schema.Mutations.TransactionsTest do
  use PaymentsApi.DataCase

  alias PaymentsApi.PaymentsFixtures

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
        fromCurrency,
        exchangeRate
      }
    }
  """

  describe "@sendMoney" do
    test "should send money from one wallet to another - different currencies" do
      # arrange
      stub(MockAlphaVantageApiWrapper, :fetch, fn %{
                                                    to_currency: _to_currency,
                                                    from_currency: _from_currency
                                                  } = params ->
        %{
          bid_price: "1.50",
          ask_price: "2.10",
          to_currency: "USD",
          exchange_rate: "2.0",
          from_currency: "CAD",
          last_refreshed: DateTime.now!("Etc/UTC")
        }
      end)

      Process.sleep(5000)

      # act
      user1 = PaymentsFixtures.user_fixture(%{email: "usr1@test.com"})

      wallet1 =
        PaymentsFixtures.wallet_fixture(%{user_id: to_string(user1.id), currency: "CAD"})

      user2 = PaymentsFixtures.user_fixture(%{email: "usr2@test.com"})

      wallet2 =
        PaymentsFixtures.wallet_fixture(%{user_id: to_string(user2.id), currency: "USD"})

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

      assert data["sendMoney"]["amount"] == "40000"
      assert data["sendMoney"]["status"] == "PENDING"
      assert data["sendMoney"]["toCurrency"] == "USD"
      assert data["sendMoney"]["fromCurrency"] == "CAD"
      assert data["sendMoney"]["description"] == "test transaction"
    end

    test "should send money from one wallet to another - different currencies and alpha vantage api in error" do
      # arrange
      stub(MockAlphaVantageApiWrapper, :fetch, fn %{
                                                    to_currency: _to_currency,
                                                    from_currency: _from_currency
                                                  } = params ->
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

      Process.sleep(5000)

      # act
      user1 = PaymentsFixtures.user_fixture(%{email: "usr1@test.com"})

      wallet1 =
        PaymentsFixtures.wallet_fixture(%{user_id: to_string(user1.id), currency: "CAD"})

      user2 = PaymentsFixtures.user_fixture(%{email: "usr2@test.com"})

      wallet2 =
        PaymentsFixtures.wallet_fixture(%{user_id: to_string(user2.id), currency: "USD"})

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

    test "should send money from one wallet to another - same currencies and alpha vantage api in error" do
      # arrange
      stub(MockAlphaVantageApiWrapper, :fetch, fn %{
                                                    to_currency: _to_currency,
                                                    from_currency: _from_currency
                                                  } = params ->
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

      Process.sleep(5000)

      # act
      user1 = PaymentsFixtures.user_fixture(%{email: "usr1@test.com"})

      wallet1 =
        PaymentsFixtures.wallet_fixture(%{user_id: to_string(user1.id), currency: "BRL"})

      user2 = PaymentsFixtures.user_fixture(%{email: "usr2@test.com"})

      wallet2 =
        PaymentsFixtures.wallet_fixture(%{user_id: to_string(user2.id), currency: "BRL"})

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
      assert data["sendMoney"]["exchangeRate"] == "100"
      assert data["sendMoney"]["description"] == "test transaction"
    end
  end
end
