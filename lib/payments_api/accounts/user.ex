defmodule PaymentsApi.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string

    timestamps()
  end

  @available_fields [:email]

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @available_fields)
    |> validate_required(@available_fields)
    |> unique_constraint(:email, message: "E-mail already taken")
  end
end
