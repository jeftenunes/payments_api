defmodule PaymentsApiWeb.Schema.Types.User do
  use Absinthe.Schema.Notation

  object :user do
    field(:id, :id)
    field(:key, :string)
    field(:username, :string)
  end
end
