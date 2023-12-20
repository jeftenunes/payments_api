defmodule PaymentsApi.Payments.Transaction do
  alias PaymentsApi.Payments.{Wallet, Transaction}

  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query, warn: false

  schema "transactions" do
    field :source, :id
    field :recipient, :id
    field :status, :string
    field :amount, :integer
    field :description, :string
    field :exchange_rate, :integer

    timestamps()
  end

  @required_fields [:amount, :source, :recipient, :status, :exchange_rate]
  @available_fields [:amount, :source, :recipient, :description, :status, :exchange_rate]

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, @available_fields)
    |> validate_required(@required_fields)
  end

  def build_retrieve_transactions_to_process_query() do
    from(
      t in Transaction,
      where: t.status == "PENDING",
      limit: 100
    )
  end

  def build_find_transaction_history_for_wallet_qry(wallet_id) do
    from(t in Transaction,
      where: (t.source == ^wallet_id or t.recipient == ^wallet_id) and t.status == "PROCESSED"
    )
  end

  def build_find_transaction_history_for_user_qry(user_id) do
    from(w in Wallet,
      join: t in Transaction,
      on: w.id == t.source or w.id == t.recipient,
      where: w.user_id == ^user_id and t.status == "PROCESSED",
      select: %{
        wallet_id: w.id,
        amount: t.amount,
        source: t.source,
        user_id: w.user_id,
        currency: w.currency,
        transaction_id: t.id,
        recipient: t.recipient
      }
    )
  end
end
