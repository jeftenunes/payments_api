defmodule PaymentsApiWeb.Schema do
  use Absinthe.Schema

  import_types(PaymentsApiWeb.Schema.Types.User)
  import_types(PaymentsApiWeb.Schema.Queries.Users)
  import_types(PaymentsApiWeb.Schema.Mutations.Users)

  import_types(PaymentsApiWeb.Schema.Types.Wallet)
  import_types(PaymentsApiWeb.Schema.Queries.Wallets)
  import_types(PaymentsApiWeb.Schema.Mutations.Wallets)

  import_types(PaymentsApiWeb.Schema.Types.Transaction)
  import_types(PaymentsApiWeb.Schema.Mutations.Transactions)

  import_types(PaymentsApiWeb.Schema.Types.TotalWorth)

  import_types(PaymentsApiWeb.Schema.Types.ExchangeRate)
  import_types(PaymentsApiWeb.Schema.Types.ConfiguredExchangeRates)

  import_types(PaymentsApiWeb.Schema.Subscriptions.UserWorth)
  import_types(PaymentsApiWeb.Schema.Subscriptions.ExchangeRate)

  @desc "Queries resources"
  query do
    import_fields(:users_queries)
    import_fields(:wallets_queries)
  end

  @desc "Mutates resources"
  mutation do
    import_fields(:users_mutations)
    import_fields(:wallets_mutations)
    import_fields(:transactions_mutations)
  end

  @desc "Follows state changes - real time"
  subscription do
    import_fields(:user_worth_subscriptions)
    import_fields(:exchange_rate_subscriptions)
  end

  def my_subscription_callback(_parent, _args, _info) do
    IO.puts("Assinatura ativada! Faça algo aqui.")
    # Chame a função que você deseja executar ao ativar a assinatura
  end
end
