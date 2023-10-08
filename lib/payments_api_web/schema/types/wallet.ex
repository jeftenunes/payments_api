defmodule PaymentsApiWeb.Schema.Types.Wallet do
  use Absinthe.Schema.Notation

  object :wallet do
    field :id, :id
    field :user_id, :id
    field :balance, :string
    field :currency, :string
  end
end
