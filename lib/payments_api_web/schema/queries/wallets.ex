defmodule PaymentsApiWeb.Schema.Queries.Wallets do
  use Absinthe.Schema.Notation

  object :wallets_queries do
    field :wallets, list_of(:wallet) do
      arg(:user_id, non_null(:id))
      arg(:currency, :string)
    end
  end
end
