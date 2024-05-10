defmodule PaymentsApi.Payments.Transaction do
  use Ecto.Schema

  alias PaymentsApi.Accounts.Wallet

  import Ecto.Changeset
  import Ecto.Query, warn: false

  schema "transactions" do
    field :type, :string
    field :status, :string
    field :amount, :integer
    field :description, :string
    field :exchange_rate, :integer

    belongs_to :wallet, Wallet

    timestamps()
  end

  @required_fields [:type, :amount, :status, :exchange_rate]

  @available_fields [
    :type,
    :amount,
    :status,
    :description,
    :exchange_rate
  ]

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, @available_fields)
    |> validate_required(@required_fields)
  end
end
