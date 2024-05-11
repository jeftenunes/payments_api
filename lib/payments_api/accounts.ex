defmodule PaymentsApi.Accounts do
  alias PaymentsApi.Repo
  alias EctoShorts.Actions
  alias PaymentsApi.Payments
  alias PaymentsApi.Currencies
  alias PaymentsApi.Accounts.{User, Wallet}
  alias PaymentsApi.Accounts.UserTotalWorth

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
    case Actions.create(User, params) do
      {:ok, usr} ->
        {:ok, usr}

      {:error, %{errors: [email: {msg, [_ | _]}]}} ->
        {:error, msg}

      {:error, _changeset} ->
        {:error, "An error occurred processing your request"}
    end
  end

  def list_wallets(params) do
    {:ok, Actions.all(Wallet, params)}
  end

  def create_wallet(%{user_id: user_id, currency: currency} = params) do
    case {user_exists?(user_id), Currencies.supported?(currency)} do
      {{:ok, _user}, true} ->
        Repo.transaction(fn ->
          {:ok, %{id: wallet_id} = wallet} = Actions.create(Wallet, params)

          first_transaction = %{
            type: "CREDIT",
            amount: 10000,
            exchange_rate: 1,
            status: "PROCESSED",
            description: "WALLET LOAD",
            recipient_wallet_id: wallet_id
          }

          {:ok, _created_transaction} = Payments.create_transaction(first_transaction)

          wallet
        end)

      {{:error, message}, _} ->
        {:error, message}

      {_, false} ->
        {:error, "Currency not supported"}
    end
  end

  def retrieve_user_total_worth(%{user_id: user_id, currency: currency} = params) do
    case {user_exists?(user_id), Currencies.supported?(currency)} do
      {{:ok, _user}, true} ->
        usr_total_worth = UserTotalWorth.retrieve_user_total_worth(params)

        IO.inspect(usr_total_worth)

        {:ok, usr_total_worth}

      {{:error, message}, _} ->
        {:error, message}

      {_, false} ->
        {:error, "Currency not supported"}
    end
  end
end
