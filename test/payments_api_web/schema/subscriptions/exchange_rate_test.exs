defmodule PaymentsApiWeb.Schema.Subscriptions.ExchangeRateTest do
  use PaymentsApiWeb.DataCase
  use PaymentsApiWeb.SubscriptionCase

  alias PaymentsApi.{PaymentsFixtures, PaymentsHelpers}

  import Mox

  setup [:set_mox_global]

  describe "exchangeRateUpdatedForCurrency" do
    test "exchange rate updated for specific currency" do
      {usr, wallet} = setup_usr(%{email})
    end
  end

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
