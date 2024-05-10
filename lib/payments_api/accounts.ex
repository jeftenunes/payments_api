defmodule PaymentsApi.Accounts do
  alias EctoShorts.Actions
  alias PaymentsApi.Currencies
  alias PaymentsApi.Accounts.{User, Wallet}

  def all_users do
    {:ok, Actions.all(User)}
  end

  def get_user_by(params) do
    case Actions.find(User, params) do
      {:ok, usr} ->
        {:ok, usr}

      {:error, %{code: :not_found}} ->
        {:error, "User not found"}

      {:error, _} ->
        {:error, "Unexpected error"}
    end
  end

  def user_exists?(id) do
    get_user_by(%{id: id})
  end

  def create_user(%{email: _email} = params) do
    Actions.create(User, params)
  end

  def list_wallets(params) do
    {:ok, Actions.all(Wallet, params)}
  end

  def create_wallet(%{user_id: user_id, currency: currency} = params) do
    case {user_exists?(user_id), Currencies.supported?(currency)} do
      {{:ok, _user}, true} -> Actions.create(Wallet, params)
      {{:error, message}, _} -> {:error, message}
      {_, false} -> {:error, "Currency not supported"}
    end
  end
end
