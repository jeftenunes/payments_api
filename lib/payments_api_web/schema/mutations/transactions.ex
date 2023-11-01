defmodule PaymentsApiWeb.Schema.Mutations.Transactions do
  use Absinthe.Schema.Notation

  alias PaymentsApiWeb.Resolvers.PaymentsResolver

  object :transactions_mutations do
    field :send_money, :transaction do
      arg(:amount, non_null(:string))
      arg(:sender_wallet_id, non_null(:id))
      arg(:recipient_wallet_id, non_null(:id))

      arg(:description, :string)

      resolve(&PaymentsResolver.send_money/2)
    end
  end
end
