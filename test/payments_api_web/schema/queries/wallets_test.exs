defmodule PaymentsApiWeb.Schema.Queries.WalletsTest do
  use PaymentsApi.DataCase

  alias PaymentsApi.PaymentsFixtures

  @wallets_by_filters_doc """
    query WalletsByFilters ($userId: ID!, $currency: String){
      wallets(userId: $userId, currency: $currency) {
        id,
        userId,
        currency
      }
    }
  """

  describe "wallets" do
    test "should find user's wallets by currency" do
      # arrange
      usr = PaymentsFixtures.user_fixture(%{email: "wallets_test@test.com"})
      PaymentsFixtures.wallet_fixture(%{user_id: to_string(usr.id), currency: "CAD"})
      PaymentsFixtures.wallet_fixture(%{user_id: to_string(usr.id), currency: "USD"})

      # act
      assert {:ok, %{data: data}} =
               Absinthe.run(
                 @wallets_by_filters_doc,
                 PaymentsApiWeb.Schema,
                 variables: %{"userId" => usr.id, "currency" => "CAD"}
               )

      # assert
      id = usr.id

      assert [
               %{"id" => _, "userId" => id, "currency" => "CAD"}
             ] = data["wallets"]
    end

    test "should find user's wallets" do
      # arrange
      usr = PaymentsFixtures.user_fixture(%{email: "wallets_test@test.com"})
      PaymentsFixtures.wallet_fixture(%{user_id: to_string(usr.id), currency: "CAD"})
      PaymentsFixtures.wallet_fixture(%{user_id: to_string(usr.id), currency: "USD"})

      # act
      assert {:ok, %{data: data}} =
               Absinthe.run(
                 @wallets_by_filters_doc,
                 PaymentsApiWeb.Schema,
                 variables: %{"userId" => usr.id}
               )

      # assert
      id = usr.id

      assert [
               %{"id" => _, "userId" => id, "currency" => "CAD"},
               %{"id" => _, "userId" => id, "currency" => "USD"}
             ] = data["wallets"]
    end
  end
end
