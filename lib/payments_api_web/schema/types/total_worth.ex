defmodule PaymentsApiWeb.Schema.Types.TotalWorth do
  use Absinthe.Schema.Notation

  object :total_worth do
    field :user_id, :id
    field :currency, :string
    field :total_worth, :string
    field :exchange_rate, :string
  end
end
