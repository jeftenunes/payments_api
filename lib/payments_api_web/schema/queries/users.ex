defmodule PaymentsApiWeb.Schema.Queries.Users do
  use Absinthe.Schema.Notation

  alias PaymentsApiWeb.Resolvers.UsersResolver

  object :users_queries do
    field :user, :user do
      arg(:id, non_null(:id))
      arg(:currency, :string)

      resolve(&UsersResolver.find_user_by/2)
    end

    field :users, list_of(:user) do
      resolve(&UsersResolver.all_users/2)
    end
  end
end
