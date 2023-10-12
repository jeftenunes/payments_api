defmodule PaymentsApi.Payments.Wallet do
  use Ecto.Schema

  import Ecto.Changeset

  schema "wallets" do
    field :userid, :id
    field :balance, :integer
    field :currency, :string

    belongs_to(:user, PaymentsApi.Payments.User)
    has_many(:transactions, PaymentsApi.Payments.Transaction)

    timestamps()
  end

  @available_fields [:userid, :balance, :currency]

  @doc false
  def changeset(wallet, attrs) do
    wallet
    |> cast(attrs, @available_fields)
    |> validate_required(@available_fields)
  end
end
