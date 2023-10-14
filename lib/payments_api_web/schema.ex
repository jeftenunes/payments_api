defmodule PaymentsApiWeb.Schema do
  use Absinthe.Schema

  import_types(PaymentsApiWeb.Schema.Types.User)
  import_types(PaymentsApiWeb.Schema.Queries.Users)
  import_types(PaymentsApiWeb.Schema.Mutations.Users)

  import_types(PaymentsApiWeb.Schema.Types.Wallet)
  import_types(PaymentsApiWeb.Schema.Queries.Wallets)
  import_types(PaymentsApiWeb.Schema.Mutations.Wallets)

  @desc "Queries resources"
  query do
    import_fields(:users_queries)
    import_fields(:wallets_queries)
  end

  @desc "Mutates resources"
  mutation do
    import_fields(:users_mutations)
    import_fields(:wallets_mutations)
  end
end
