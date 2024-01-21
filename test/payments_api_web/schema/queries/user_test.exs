defmodule PaymentsApiWeb.Schema.Queries.UserTest do
  use PaymentsApi.DataCase

  @user_by_email_doc """
    query UserByEmail ($email: String!){
      user(email: $email) {
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

  @all_users_doc """
    query Users {
      users {
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
    test "should find all users" do
      assert {:ok, %{data: data}} =
               Absinthe.run(@all_users_doc, PaymentsApiWeb.Schema, variables: %{})

      assert [
               %{
                 "email" => "test@email.com",
                 "id" => _,
                 "wallets" => usr1_wallets
               },
               %{
                 "email" => "test1@email.com",
                 "id" => _,
                 "wallets" => usr2_wallets
               }
             ] = data["users"]

      assert [%{"currency" => "BRL"}, %{"currency" => "CAD"}] = usr1_wallets

      assert [] = usr2_wallets
    end

    test "should find user by email" do
      assert {:ok, %{data: data}} =
               Absinthe.run(@user_by_email_doc, PaymentsApiWeb.Schema,
                 variables: %{"email" => "test@email.com"}
               )

      user_id = data["user"]["id"]

      assert data["user"]["email"] == "test@email.com"

      assert [
               %{"id" => _, "userId" => user_id, "currency" => "BRL"},
               %{"id" => _, "userId" => user_id, "currency" => "CAD"}
             ] = data["user"]["wallets"]
    end
  end
end
