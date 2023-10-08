defmodule PaymentsApi.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :private_key, :string

    has_many(:wallets, PaymentsApi.Accounts.Wallet)

    timestamps()
  end

  @available_fields [:private_key, :email]

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @available_fields)
    |> validate_required(@available_fields)
  end
end
