defmodule PaymentsApi.Payments.Transaction do
  alias PaymentsApi.Payments.Transaction

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

  def find_transaction_history_for_wallet(wallet_id) do
    from(t in Transaction)
    |> where([t], field(t, :source) == ^wallet_id)
    |> or_where([t], field(t, :recipient) == ^wallet_id)

    # NOT GONNA PAGINATE, IN A REAL APP, IT'D BE NEEDED
  end
end
