defmodule PaymentsApi.Payments.Transaction do
  alias PaymentsApi.Payments.{Wallet, Transaction}

  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query, warn: false

  schema "transactions" do
    field :type, :string
    field :wallet_id, :id
    field :status, :string
    field :amount, :integer
    field :description, :string
    field :exchange_rate, :integer
    field :origin_transaction_id, :integer

    timestamps()
  end

  @required_fields [:type, :amount, :wallet_id, :status, :exchange_rate]
  @available_fields [
    :type,
    :amount,
    :wallet_id,
    :description,
    :status,
    :exchange_rate,
    :origin_transaction_id
  ]

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, @available_fields)
    |> validate_required(@required_fields)
  end

  def build_retrieve_transactions_to_process_query do
    from t in Transaction,
      where: t.status == "PENDING" and t.type == "DEBIT",
      limit: 100
  end

  def build_find_transaction_history_for_wallet_qry(wallet_id) do
    from t in Transaction,
      where: t.wallet_id == ^wallet_id and t.status == "PROCESSED"
  end

  def build_find_transaction_history_by_origin_qry(origin_transaction_id) do
    from t in Transaction,
      where: t.origin_transaction_id == ^origin_transaction_id and t.status == "PENDING"
  end

  def build_find_transaction_history_for_user_qry(user_id) do
    from w in Wallet,
      join: t in Transaction,
      on: w.id == t.wallet_id,
      where: w.user_id == ^user_id and t.status == "PROCESSED",
      select: %{
        type: t.type,
        wallet_id: w.id,
        amount: t.amount,
        user_id: w.user_id,
        currency: w.currency,
        transaction_id: t.id
      }
  end
end
