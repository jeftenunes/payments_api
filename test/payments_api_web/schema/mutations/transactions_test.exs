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
    test "should send money from one wallet to another" do
      # arrange
      parent = self()

      expect(MockAlphaVantageApiWrapper, :fetch, 100_000, fn _params ->
        %{
          bid_price: "1.50",
          ask_price: "2.10",
          to_currency: "USD",
          exchange_rate: "2.0",
          from_currency: "CAD",
          last_refreshed: DateTime.now!("Etc/UTC")
        }
      end)

      Task.async(fn ->
        MockAlphaVantageApiWrapper |> allow(parent, self())
        spawn(fn -> MockAlphaVantageApiWrapper.fetch(%{}) end)
      end)
      |> Task.await()

      # TODO:fix - don't use a timer
      :timer.sleep(2000)
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

      # IO.inspect(data)
      # IO.inspect(errors)
    end
  end
end
