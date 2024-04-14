defmodule PaymentsApi.Payments do
  @moduledoc """
  The Payments context.
  """

  alias PaymentsApi.Payments.{
    Users,
    Wallets,
    Transactions
  }

  def all_users, do: Users.list_users(%{})
  def create_user(attrs), do: Users.create_user(attrs)
  def get_users_by_email(email), do: Users.get_user_by(%{email: email})

  def send_money(%{} = attrs),
    do: PaymentsApi.Payments.Transactions.create_transaction(attrs)

  def create_wallet(params) do
    case Wallets.create_wallet(params) do
      wallet when is_map(wallet) ->
        Transactions.load_wallet(wallet.id)
        {:ok, wallet}

      errors when is_list(errors) ->
        errors
    end
  end

  def list_wallets(params),
    do: Wallets.list_wallets(params)
end
