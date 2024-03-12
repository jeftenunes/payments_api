defmodule PaymentsApiWeb.Schema.Mutations.UsersTest do
  use PaymentsApiWeb.DataCase

  alias PaymentsApi.PaymentsFixtures

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

    test "should create an user when the user's email is already taken" do
      # arrange
      PaymentsFixtures.user_fixture(%{email: "email@test.com"})

      # act
      assert {:ok, %{errors: errors, data: data}} =
               Absinthe.run(@create_user_doc, PaymentsApiWeb.Schema,
                 variables: %{
                   "email" => "email@test.com"
                 }
               )

      # assert
      assert data["createdUser"] == nil
      # Yes, I know in real world we must not return "Emaill already taken".
      assert List.first(errors)[:message] === "E-mail already taken"
    end
  end
end
