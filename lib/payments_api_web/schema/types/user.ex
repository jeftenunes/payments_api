defmodule PaymentsApiWeb.Schema.Types.User do
  use Absinthe.Schema.Notation

  object :user do
    field(:id, :id)
    field(:email, :string)
    field(:private_key, :string)
  end
end
