defmodule PaymentsApiWeb.Resolvers.WalletsResolver do
  use Absinthe.Schema.Notation

  alias PaymentsApi.Payments
  alias PaymentsApiWeb.Resolvers.ErrorsHelper

  def create_wallet(%{user_id: _user_id, currency: _currency} = params, _) do
    case Payments.create_wallet(params) do
      {:ok, wallet} ->
        {:ok, wallet}

      errors when is_list(errors) ->
        ErrorsHelper.build_graphql_error(errors)
    end
  end

  def find_wallets(params, _) do
    {:ok, Payments.list_wallets(params)}
  end
end
