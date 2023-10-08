defmodule PaymentsApi.Payments.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions" do
    field :source, :id
    field :status, :string
    field :amount, :integer
    field :description, :string

    belongs_to(:wallet, PaymentsApi.Accounts.Wallet)

    timestamps()
  end

  @available_fields [:amount, :description, :status]

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, @available_fields)
    |> validate_required(@available_fields)
  end
end
