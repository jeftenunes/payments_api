defmodule PaymentsApiWeb.Schema do
  use Absinthe.Schema

  import_types(PaymentsApiWeb.Schema.Types.User)
  import_types(PaymentsApiWeb.Schema.Queries.Users)

  query do
    import_fields(:users_queries)
  end
end
