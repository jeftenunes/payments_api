defmodule PaymentsApiWeb.Schema.Types.User do
  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers, only: [dataloader: 2]

  object :user do
    field :id, :id
    field :email, :string
    field :wallets, list_of(:wallet), resolve: dataloader(PaymentsApi.Accounts, :wallets)
  end
end
