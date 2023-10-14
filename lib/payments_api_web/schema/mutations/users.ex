defmodule PaymentsApiWeb.Schema.Mutations.Users do
  alias PaymentsApiWeb.Resolvers.UsersResolver

  use Absinthe.Schema.Notation

  object :users_mutations do
    field :create_user, :user do
      arg(:email, :string)

      resolve(&UsersResolver.create_user/2)
    end
  end
end
