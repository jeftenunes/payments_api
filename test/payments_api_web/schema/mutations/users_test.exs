defmodule PaymentsApiWeb.Schema.Mutations.UsersTest do
  use PaymentsApi.DataCase

  @create_user_doc """
    mutation CreateUser($email: String!) {
      createUser(email: $email) {
        id
        email
      }
    }
  """

  describe "@createUser" do
    test "should create an user" do
      # act
      assert {:ok, %{data: data}} =
               Absinthe.run(@create_user_doc, PaymentsApiWeb.Schema,
                 variables: %{
                   "email" => "email@test.com"
                 }
               )

      # assert
      assert %{"email" => "email@test.com", "id" => _} = data["createUser"]
    end
  end
end
