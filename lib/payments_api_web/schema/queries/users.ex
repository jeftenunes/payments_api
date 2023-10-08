defmodule PaymentsApiWeb.Schema.Queries.Users do
  alias PaymentsApiWeb.Resolvers.UsersResolver

  use Absinthe.Schema.Notation

  object :users_queries do
    field :user, :user do
      arg(:id, non_null(:id))

      resolve(&UsersResolver.find_by/2)
    end
  end
end
