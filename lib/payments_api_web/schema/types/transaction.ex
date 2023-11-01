defmodule PaymentsApiWeb.Schema.Types.Transaction do
  use Absinthe.Schema.Notation

  object :transaction do
    field :id, :id
    field :source, :id
    field :recipient, :id
    field :status, :string
    field :amount, :string
    field :description, :string
    field :exchange_rate, :string
  end
end
