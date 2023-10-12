defmodule PaymentsApi.PaymentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PaymentsApi.Payments` context.
  """

  @doc """
  Generate a wallet.
  """
  def wallet_fixture(attrs \\ %{}) do
    {:ok, wallet} =
      attrs
      |> Enum.into(%{})
      |> PaymentsApi.Payments.create_wallet()

    wallet
  end

  @doc """
  Generate a transaction.
  """
  def transaction_fixture(attrs \\ %{}) do
    {:ok, transaction} =
      attrs
      |> Enum.into(%{})
      |> PaymentsApi.Payments.create_transaction()

    transaction
  end
end
