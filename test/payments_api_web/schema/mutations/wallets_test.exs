defmodule PaymentsApiWeb.Schema.Mutations.WalletsTest do
  use PaymentsApi.DataCase

  alias PaymentsApi.PaymentsFixtures

  @create_wallet_doc """
    mutation CreateWallet($userId: ID!, $currency: String!) {
      createWallet(userId: $userId, currency: $currency) {
        id,
        userId,
        currency
      }
    }
  """

  describe "@createWallet" do
    test "should create a wallet" do
      # arrange
      usr = PaymentsFixtures.user_fixture(%{email: "wallets_test@test.com"})

      # act
      assert {:ok, %{data: data}} =
               Absinthe.run(@create_wallet_doc, PaymentsApiWeb.Schema,
                 variables: %{
                   "userId" => usr.id,
                   "currency" => "USD"
                 }
               )

      # assert
      id = usr.id
      assert data["createWallet"]["userId"] == to_string(id)

      IO.inspect(data["createWallet"])
    end
  end
end
