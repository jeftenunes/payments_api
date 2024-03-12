defmodule PaymentsApi.Payments.Wallet do
  use Ecto.Schema

  alias PaymentsApi.Payments.{Wallet, User}

  import Ecto.Query, warn: false
  import Ecto.Changeset

  schema "wallets" do
    field :currency, :string

    belongs_to :user, PaymentsApi.Payments.User

    timestamps()
  end

  @available_fields [:user_id, :currency]

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

  def build_fetch_wallets_qry(source_id, recipient_id) do
    from(credit_wallet in Wallet,
      join: debit_wallet in Wallet,
      on: credit_wallet.id == ^source_id and debit_wallet.id == ^recipient_id,
      select: %{source: debit_wallet, recipient: credit_wallet}
    )
  end

  def build_find_user_by_wallet_id_qry(wallet_id) do
    from(u in User,
      join: w in Wallet,
      on: u.id == w.user_id,
      where: w.id == ^wallet_id
    )
  end
end
