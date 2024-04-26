defmodule PaymentsApiWeb.Schema.Mutations.Wallets do
  alias PaymentsApiWeb.Resolvers.WalletsResolver

  use Absinthe.Schema.Notation

  object :wallets_mutations do
    field :create_wallet, :wallet do
      arg :user_id, non_null(:id)
      arg :currency, non_null(:string)

      resolve &WalletsResolver.create_wallet/2
    end
  end
end
