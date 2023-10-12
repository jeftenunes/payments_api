defmodule PaymentsApi.Payments.User do
  use Ecto.Schema

  import Ecto.Query, only: [from: 2], warn: false

  alias PaymentsApi.Repo
  alias PaymentsApi.Payments.User

  schema "users" do
    field :email, :string
    has_many(:wallets, PaymentsApi.Payments.Wallet)

    timestamps()
  end

  def exists?(user_id) do
    qry =
      from u in User,
        where: u.id == ^user_id

    Repo.exists?(qry)
  end
end
