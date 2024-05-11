defmodule PaymentsApi.Payments.Transaction do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query, warn: false

  schema "transactions" do
    field :type, :string
    field :status, :string
    field :amount, :integer
    field :description, :string
    field :exchange_rate, :integer
    field :source_wallet_id, :integer
    field :recipient_wallet_id, :integer

    timestamps()
  end

  @required_fields [
    :type,
    :amount,
    :status,
    :exchange_rate,
    :recipient_wallet_id
  ]

  @available_fields [
    :type,
    :amount,
    :status,
    :description,
    :exchange_rate,
    :source_wallet_id,
    :recipient_wallet_id
  ]

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, @available_fields)
    |> validate_required(@required_fields)
  end
end
