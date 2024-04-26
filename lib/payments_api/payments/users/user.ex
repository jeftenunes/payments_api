defmodule PaymentsApi.Payments.Users.User do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias PaymentsApi.Payments.{Users.User, Wallets.Wallet}

  schema "users" do
    field :email, :string

    has_many :wallets, Wallet

    timestamps()
  end

  @available_fields [:email]

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @available_fields)
    |> validate_required(@available_fields)
    |> unique_constraint(:email, message: "E-mail already taken")
  end

  def build_exists_qry(user_id) do
    from u in User,
      where: u.id == ^user_id
  end

  def find_user_by_email(email) do
    qry = join_users_wallets()

    where(qry, [u], u.email == ^email)
  end

  def find_users(user_id) when is_integer(user_id),
    do: build_find_users_qry(%{user_id: user_id})

  def find_users(%{} = params),
    do: build_find_users_qry(params)

  def find_users(%{user_id: _user_id, currency: _currency} = params),
    do: build_find_users_qry(params)

  def build_find_user_by_id_qry(user_id),
    do: build_find_users_qry(%{user_id: user_id})

  def build_find_users_qry(params \\ %{}) do
    qry =
      join_users_wallets()

    Enum.reduce(params, qry, fn {field, val}, q ->
      where(q, [u, w], field(w, ^field) == ^val)
    end)
  end

  defp join_users_wallets do
    from(u in User,
      left_join: w in Wallet,
      on: u.id == w.user_id,
      select: %{user: u, wallet: w}
    )
  end
end
