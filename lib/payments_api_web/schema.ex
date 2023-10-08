defmodule PaymentsApiWeb.Schema do
  use Absinthe.Schema

  import_types(PaymentsApiWeb.Schema.Types.User)
  import_types(PaymentsApiWeb.Schema.Queries.Users)
  import_types(PaymentsApiWeb.Schema.Mutations.Users)

  @desc "Queries users"
  query do
    import_fields(:users_queries)
  end

  @desc "Mutates users"
  mutation do
    import_fields(:users_mutations)
  end
end
