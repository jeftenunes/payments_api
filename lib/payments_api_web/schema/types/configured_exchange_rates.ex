defmodule PaymentsApiWeb.Schema.Types.ConfiguredExchangeRates do
  use Absinthe.Schema.Notation

  object :configured_exchange_rates do
    field :currency, :string
    field :exchange_rates, list_of(:exchange_rate)
  end
end
