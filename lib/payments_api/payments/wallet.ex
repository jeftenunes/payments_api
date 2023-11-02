defmodule PaymentsApi.Payments.Wallet do
  alias PaymentsApi.Payments.Wallet
  use Ecto.Schema

  import Ecto.Query, warn: false
  import Ecto.Changeset

  schema "wallets" do
    field :balance, :integer
    field :currency, :string

    belongs_to(:user, PaymentsApi.Payments.User)

    timestamps()
  end

  @available_fields [:user_id, :balance, :currency]

  @doc false
  def changeset(wallet, attrs) do
    wallet
    |> cast(attrs, @available_fields)
    |> validate_required(@available_fields)
  end

  def build_find_wallets_by_qry(params) do
    qry = from(w in Wallet, select: w)

    Enum.reduce(params, qry, fn {field, val}, q ->
      where(q, [w], field(w, ^field) == ^val)
    end)
  end
end
