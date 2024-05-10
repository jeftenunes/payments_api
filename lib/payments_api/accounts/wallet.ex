defmodule PaymentsApi.Accounts.Wallet do
  use Ecto.Schema

  alias PaymentsApi.Accounts.User

  import Ecto.Query, warn: false
  import Ecto.Changeset

  schema "wallets" do
    field :currency, :string

    belongs_to :user, User

    timestamps()
  end

  @available_fields [:user_id, :currency]

  @doc false
  def changeset(wallet, attrs) do
    wallet
    |> cast(attrs, @available_fields)
    |> validate_required(@available_fields)
    |> foreign_key_constraint(:user_id)
  end
end
