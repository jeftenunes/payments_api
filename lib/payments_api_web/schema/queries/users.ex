defmodule PaymentsApiWeb.Schema.Queries.Users do
  use Absinthe.Schema.Notation

  object :users_queries do
    field :user, :user do
      arg(:id, non_null(:id))

      resolve(fn params, _ -> {:ok, %{name: "bubu", id: params.id}} end)
    end
  end
end
