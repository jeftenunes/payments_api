defmodule PaymentsApiWeb.Schema.Queries.Wallets do
  alias PaymentsApiWeb.Resolvers.WalletsResolver
  use Absinthe.Schema.Notation

  object :wallets_queries do
    field :wallets, list_of(:wallet) do
      arg(:user_id, non_null(:id))
      arg(:currency, :string)

      resolve(&WalletsResolver.find_wallets/2)
    end
  end
end
