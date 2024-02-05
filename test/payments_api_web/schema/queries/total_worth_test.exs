defmodule PaymentsApiWeb.Schema.Queries.TotalWorthTest do
  use PaymentsApi.DataCase

  describe "totalWorth" do
    test "should retrieve user correct total worth after creating a wallet" do
      # arrange
      usr = PaymentsFixtures.user_fixture(%{email: "total_worth_test@test.com"})

      wallet1 =
        PaymentsFixtures.wallet_fixture(%{user_id: to_string(user1.id), currency: "CAD"})
    end
  end
end
