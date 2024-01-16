defmodule PaymentsApiWeb.Schema.Queries.UserTest do
  use PaymentsApi.DataCase

  @user_by_id_doc """
    query UserById ($id: ID!){
      user(id: $id) {
        id,
        email,
        wallets {
          id,
          userId,
          currency
        }
      }
    }
  """

  describe "users" do
    test "should find user by id" do
    end
  end
end
