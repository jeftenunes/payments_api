defmodule PaymentsApi.Payments.User do
  use Ecto.Schema

  schema "users" do
    field :email, :string
    has_many(:wallets, PaymentsApi.Payments.Wallet)

    timestamps()
  end
end
