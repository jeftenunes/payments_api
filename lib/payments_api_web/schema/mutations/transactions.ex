defmodule PaymentsApiWeb.Schema.Mutations.Transactions do
  use Absinthe.Schema.Notation

  alias PaymentsApiWeb.Resolvers.PaymentsResolver

  object :transactions_mutations do
    field :send_money, :transaction do
      arg :source, non_null(:id)
      arg :recipient, non_null(:id)

      arg :description, :string
      arg :amount, non_null(:string)

      resolve &PaymentsResolver.send_money/2
    end
  end
end
