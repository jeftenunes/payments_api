defmodule PaymentsApiWeb.Schema.Subscriptions.UserTotalWorthTest do
  alias PaymentsApi.{PaymentsFixtures, PaymentsHelpers}

  import Mox

  setup [:set_mox_global]

  @create_user_doc """
    mutation CreateUser($email: String!) {
      createUser(email: $email) {
        id
        email
      }
    }
  """

  @create_wallet_doc """
    mutation CreateWallet($userId: ID!, $currency: String!) {
      createWallet(userId: $userId, currency: $currency) {
        id,
        userId,
        currency
      }
    }
  """

  @send_money_doc """
    mutation SendMoney($amount: String!, $description: String, $recipient: ID!, $source: ID!) {
      sendMoney(amount: $amount, description: $description, recipient: $recipient, source: $source) {
        amount,
        status,
        source,
        recipient,
        toCurrency,
        description,
        fromCurrency
      }
    }
  """

  defp setup_usr(%{email: email} = _params) do
    assert {:ok, %{data: data}} =
             Absinthe.run(@create_user_doc, PaymentsApiWeb.Schema,
               variables: %{
                 "email" => email
               }
             )

    usr = data["createUser"]

    assert {:ok, %{data: data}} =
             Absinthe.run(@create_wallet_doc, PaymentsApiWeb.Schema,
               variables: %{
                 "userId" => usr.id,
                 "currency" => "USD"
               }
             )

    {usr, wallet}
  end
end
