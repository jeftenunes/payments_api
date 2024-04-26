defmodule PaymentsApi.PaymentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PaymentsApi.Payments` context.
  """

  def user_fixture(%{email: _email} = attrs) do
    {:ok, user} =
      attrs
      |> Enum.into(%{})
      |> PaymentsApi.Payments.create_user()

    user
  end

  def wallet_fixture(%{user_id: _user_id, currency: _currency} = attrs) do
    {:ok, wallet} =
      attrs
      |> Enum.into(%{})
      |> PaymentsApi.Payments.create_wallet()

    wallet
  end

  def transaction_fixture(
        %{amount: "2", source: "5", recipient: "4", description: "brl -> USD"} = attrs
      ) do
    {:ok, transaction} =
      attrs
      |> Enum.into(%{})
      |> PaymentsApi.Payments.send_money()

    transaction
  end
end
