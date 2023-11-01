defmodule PaymentsApiWeb.Schema.Types.Transaction do
  use Absinthe.Schema.Notation

  object :transaction do
    field :id, :id
    field :source, :id
    field :status, :string
    field :amount, :integer
    field :description, :string
  end
end
