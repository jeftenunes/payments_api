defmodule PaymentsApiWeb.Resolvers.WalletsResolver do
  use Absinthe.Schema.Notation

  alias PaymentsApi.Accounts
  alias PaymentsApiWeb.Resolvers.ErrorsHelper

  def create_wallet(%{user_id: _user_id, currency: _currency} = params, _) do
    case Accounts.create_wallet(params) do
      {:ok, wallet} ->
        {:ok, wallet}

      {:error, changeset} ->
        {:error, ErrorsHelper.traverse_errors(changeset)}
    end
  end

  def find_wallets(params, _) do
    {:ok, Accounts.list_wallets(params)}
  end
end
