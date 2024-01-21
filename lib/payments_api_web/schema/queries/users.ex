defmodule PaymentsApiWeb.Schema.Queries.Users do
  use Absinthe.Schema.Notation

  alias PaymentsApiWeb.Resolvers.UsersResolver

  object :users_queries do
    field :user, :user do
      arg(:email, non_null(:string))

      resolve(&UsersResolver.find_user_by/2)
    end

    field :users, list_of(:user) do
      resolve(&UsersResolver.all_users/2)
    end

    field :total_worth, :total_worth do
      arg(:user_id, non_null(:id))
      arg(:currency, non_null(:string))

      resolve(&UsersResolver.find_user_total_worth_by/2)
    end
  end
end
