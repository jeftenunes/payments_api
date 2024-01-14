defmodule PaymentsApiWeb.Schema.Subscriptions.ExchangeRate do
  use Absinthe.Schema.Notation

  object :exchange_rate_subscriptions do
    field :exchange_rate_updated_for_currency, list_of(:exchange_rate) do
      arg(:currency, :string)

      config(fn args, _ -> {:ok, topic: "exchange_rate_updated:#{args.currency}"} end)
    end

    field :exchange_rates_updated, list_of(:configured_exchange_rates) do
      config(fn _args, _ -> {:ok, topic: "exchange_rates_updated"} end)
    end
  end
end
