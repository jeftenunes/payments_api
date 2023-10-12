defmodule PaymentsApi.Payments do
  @moduledoc """
  The Payments context.
  """

  import Ecto.Query, warn: false

  alias PaymentsApiWeb.Resolvers.ErrorsHelper
  alias PaymentsApi.Payments.Currencies.Currency
  alias PaymentsApi.Repo
  alias PaymentsApi.Payments.{Transaction, User}

  @doc """
  Returns the list of transactions.

  ## Examples

      iex> list_transactions()
      [%Transaction{}, ...]

  """
  def list_transactions do
    Repo.all(Transaction)
  end

  @doc """
  Gets a single transaction.

  Returns nil if the Transaction does not exist.

  ## Examples

      iex> get_transaction(123)
      %Transaction{}

      iex> get_transaction!456)
      nil

  """
  def get_transaction(id), do: Repo.get(Transaction, id)

  @doc """
  Creates a transaction.

  ## Examples

      iex> create_transaction(%{field: value})
      {:ok, %Transaction{}}

      iex> create_transaction(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transaction(attrs \\ %{}) do
    %Transaction{}
    |> Transaction.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a transaction.

  ## Examples

      iex> update_transaction(transaction, %{field: new_value})
      {:ok, %Transaction{}}

      iex> update_transaction(transaction, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_transaction(%Transaction{} = transaction, attrs) do
    transaction
    |> Transaction.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a transaction.

  ## Examples

      iex> delete_transaction(transaction)
      {:ok, %Transaction{}}

      iex> delete_transaction(transaction)
      {:error, %Ecto.Changeset{}}

  """
  def delete_transaction(%Transaction{} = transaction) do
    Repo.delete(transaction)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking transaction changes.

  ## Examples

      iex> change_transaction(transaction)
      %Ecto.Changeset{data: %Transaction{}}

  """
  def change_transaction(%Transaction{} = transaction, attrs \\ %{}) do
    Transaction.changeset(transaction, attrs)
  end

  alias PaymentsApi.Payments.Wallet

  @doc """
  Returns the list of wallets.

  ## Examples

      iex> list_wallets()
      [%Wallet{}, ...]

  """
  def list_wallets do
    Repo.all(Wallet)
  end

  @doc """
  Gets a single wallet.

  returns nil if the Wallet does not exist.

  ## Examples

      iex> get_wallet(123)
      %Wallet{}

      iex> get_wallet(456)
      nil

  """
  def get_wallet(id), do: Repo.get!(Wallet, id)

  @doc """
  Creates a wallet.

  ## Examples

      iex> create_wallet(%{field: value})
      {:ok, %Wallet{}}

      iex> create_wallet(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_wallet(%{currency: currency, user_id: user_id} = attrs \\ %{}) do
    case {User.exists?(user_id), Currency.is_supported?(currency)} do
      {true, true} ->
        build_wallet_initial_state(attrs)
        |> Wallet.changeset(attrs)
        |> Repo.insert()

      {false, _} ->
        ErrorsHelper.build_graphql_error(["User does not exist"])

      {_, false} ->
        ErrorsHelper.build_graphql_error(["Currency not supported"])
    end
  end

  @doc """
  Deletes a wallet.

  ## Examples

      iex> delete_wallet(wallet)
      {:ok, %Wallet{}}

      iex> delete_wallet(wallet)
      {:error, %Ecto.Changeset{}}

  """
  def delete_wallet(%Wallet{} = wallet) do
    Repo.delete(wallet)
  end

  alias PaymentsApi.Payments.Wallet

  @doc """
  Gets a single user.

  Returns nil if the Transaction does not exist.

  ## Examples

      iex> get_user(123)
      %User{}

      iex> get_user456)
      nil

  """
  def user_exists(id), do: Repo.get(User, id)

  ## helpers

  defp build_wallet_initial_state(attrs) do
    %Wallet{balance: 0, currency: attrs.currency, userid: String.to_integer(attrs.user_id)}
  end
end
