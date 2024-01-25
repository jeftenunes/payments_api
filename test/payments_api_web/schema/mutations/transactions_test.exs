defmodule PaymentsApiWeb.Schema.Mutations.TransactionsTest do
  use PaymentsApi.DataCase

  @send_money_doc """
    mutation SendMoney($amount: String!, $description: String, $recipient: String!, $source: String!) {
      sendMoney(amount: $amount, description: $description, recipient: $recipient, source: $source)
      amount
      status
      source
      recipient
      toCurrency
      description
      fromCurrency
      exchangeRate
    }
  """

  describe "@sendMoney" do
    test "should send money from one wallet to another" do
      user1 = PaymentsFixtures.user_fixture(%{email: "usr1@test.com"})
      PaymentsFixtures.wallet_fixture(%{user_id: to_string(user1.id), currency: "CAD"})

      user2 = PaymentsFixtures.user_fixture(%{email: "usr1@test.com"})
      PaymentsFixtures.wallet_fixture(%{user_id: to_string(user2.id), currency: "USD"})
    end
  end
end
