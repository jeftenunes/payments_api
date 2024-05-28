defmodule PaymentsApi.Accounts do
  alias PaymentsApi.Repo
  alias EctoShorts.Actions
  alias PaymentsApi.Currencies
  alias PaymentsApi.Payments.Transaction
  alias PaymentsApi.Accounts.{User, Wallet, UserTotalWorth}

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

          {:ok, _created_transaction} =
            Actions.create(Transaction, Transaction.build_load_wallet_transaction(wallet_id))

          wallet
        end)

      {{:error, message}, _} ->
        {:error, message}

      {_, false} ->
        {:error, "Currency not supported"}
    end
  end

  def get_wallet_by(params) do
    case Actions.find(Wallet, params) do
      {:ok, usr} ->
        {:ok, usr}

      {:error, %{code: :not_found}} ->
        {:error, "Wallet not found"}

      {:error, _} ->
        {:error, "Unexpected error"}
    end
  end

  def retrieve_user_total_worth(%{user_id: user_id, currency: currency} = params) do
    case {user_exists?(user_id), Currencies.supported?(currency)} do
      {{:ok, _user}, true} ->
        usr_total_worth = UserTotalWorth.retrieve_user_total_worth(params)

        {:ok, usr_total_worth}

      {{:error, message}, _} ->
        {:error, message}

      {_, false} ->
        {:error, "Currency not supported"}
    end
  end

  def publish_user_total_worth_updates(user_id) do
    user_total_worth =
      Enum.map(Currencies.get_supported_currencies(), fn {currency_key, _currency_infos} ->
        UserTotalWorth.retrieve_user_total_worth(%{
          user_id: user_id,
          currency: to_string(currency_key)
        })
      end)

    Absinthe.Subscription.publish(
      PaymentsApiWeb.Endpoint,
      user_total_worth,
      user_total_worth_updated: "user_total_worth_updated:#{user_id}"
    )
  end

  defdelegate calculate_balance_for_wallet(wallet_id), to: UserTotalWorth
end
