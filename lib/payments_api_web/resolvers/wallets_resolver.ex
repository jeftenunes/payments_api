defmodule PaymentsApiWeb.Resolvers.WalletsResolver do
  use Absinthe.Schema.Notation

  alias PaymentsApi.Payments

  def create_wallet(%{user_id: _user_id, currency: _currency} = params, _) do
    Payments.create_wallet(params)
  end

  # def find_by(%{user_id: user_id, currency: currency})
end
