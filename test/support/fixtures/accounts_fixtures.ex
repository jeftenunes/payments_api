defmodule PaymentsApi.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PaymentsApi.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{})
      |> PaymentsApi.Accounts.create_user()

    user
  end

  @doc """
  Generate a wallet.
  """
  def wallet_fixture(attrs \\ %{}) do
    {:ok, wallet} =
      attrs
      |> Enum.into(%{
        balance: 42
      })
      |> PaymentsApi.Accounts.create_wallet()

    wallet
  end
end
