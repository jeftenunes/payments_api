defmodule PaymentsApiWeb.Resolvers.WalletsResolver do
  alias PaymentsApi.Accounts

  use Absinthe.Schema.Notation

  def create_wallet(%{user_id: _user_id, currency: _currency} = params, _) do
    Accounts.create_wallet(params)
  end

  # def find_by(%{user_id: user_id, currency: currency})
end
