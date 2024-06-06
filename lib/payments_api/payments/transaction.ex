defmodule PaymentsApi.Payments.Transaction do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query, warn: false

  schema "transactions" do
    field :type, :string
    field :status, :string
    field :amount, :integer
    field :wallet_id, :integer
    field :description, :string
    field :exchange_rate, :float

    timestamps()
  end

  @required_fields [
    :type,
    :amount,
    :status,
    :exchange_rate
  ]

  @available_fields [
    :type,
    :amount,
    :status,
    :wallet_id,
    :description,
    :exchange_rate
  ]

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, @available_fields)
    |> validate_required(@required_fields)
  end

  def build_load_wallet_transaction(wallet_id) do
    %{
      type: "CREDIT",
      amount: 10_000,
      exchange_rate: 1,
      status: "PROCESSED",
      wallet_id: wallet_id,
      description: "WALLET LOAD"
    }
  end
end
