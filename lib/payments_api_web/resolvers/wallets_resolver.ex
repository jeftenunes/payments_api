defmodule PaymentsApiWeb.Resolvers.WalletsResolver do
  use Absinthe.Schema.Notation

  alias PaymentsApi.Accounts

  def create_wallet(%{user_id: _user_id, currency: _currency} = params, _) do
    Accounts.create_wallet(params)
  end

  def find_wallets(params, _) do
    Accounts.list_wallets(params)
  end
end
