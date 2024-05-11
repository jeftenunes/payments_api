defmodule PaymentsApi.Accounts.Wallet do
  use Ecto.Schema

  alias PaymentsApi.Payments.Transaction
  alias PaymentsApi.Accounts.{User, Wallet}

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

  # queries I couldn't do with Actions

  def find_transaction_history_for_user_qry(user_id) do
    from w in Wallet,
      join: t in Transaction,
      on: w.id == t.recipient_wallet_id,
      where: w.user_id == ^user_id and t.status == "PROCESSED",
      select: %{
        type: t.type,
        amount: t.amount,
        status: t.status,
        currency: w.currency,
        wallet_id: t.recipient_wallet_id
      }
  end
end
