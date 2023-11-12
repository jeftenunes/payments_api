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

    timestamps()
  end

  @required_fields [:amount, :source, :recipient, :status]
  @available_fields [:amount, :source, :recipient, :description, :status]

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, @available_fields)
    |> validate_required(@required_fields)
  end

  def find_pending_transactions do
    from(
      t in Transaction,
      where: t.status == "PENDING"
    )
  end
end
