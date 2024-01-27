defmodule PaymentsApiWeb.Schema.Mutations.TransactionsTest do
  use PaymentsApi.DataCase

  alias PaymentsApi.PaymentsFixtures

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
    test "should send money from one wallet to another" do
      # arrage
      user1 = PaymentsFixtures.user_fixture(%{email: "usr1@test.com"})
      wallet1 = PaymentsFixtures.wallet_fixture(%{user_id: to_string(user1.id), currency: "CAD"})

      user2 = PaymentsFixtures.user_fixture(%{email: "usr2@test.com"})
      wallet2 = PaymentsFixtures.wallet_fixture(%{user_id: to_string(user2.id), currency: "USD"})

      # # act
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
    end
  end
end
