defmodule PaymentsApiWeb.Schema.Types.ExchangeRate do
  use Absinthe.Schema.Notation

  object :exchange_rate do
    field :ask_price, :string
    field :bid_price, :string
    field :to_currency, :string
    field :from_currency, :string
    field :exchange_rate, :string
    field :last_refreshed, :string
  end
end
