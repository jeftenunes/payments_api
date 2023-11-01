defmodule PaymentsApi.Payments do
  @moduledoc """
  The Payments context.
  """

  import Ecto.Query, warn: false

  alias PaymentsApiWeb.Resolvers.ErrorsHelper
  alias PaymentsApi.Repo
  alias PaymentsApi.Payments.Transaction

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
  def create_transaction(
        %{
          amount: _amount,
          description: _description,
          sender_wallet_id: _sender_wallet_id,
          recipient_wallet_id: _recipient_wallet_id
        } = attrs
      ) do
    with true <- is_transaction_amount_format_valid?(attrs) do
      initial_transaction_state = build_initial_transaction_state(attrs)

      %Transaction{}
      |> Transaction.changeset(initial_transaction_state)
      |> Repo.insert()
    else
      false ->
        ErrorsHelper.build_graphql_error(["transaction amount bad formatted. Expecting 11,22"])
    end
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

  defp build_initial_transaction_state(%{
         amount: amount,
         description: description,
         sender_wallet_id: sender_wallet_id,
         recipient_wallet_id: recipient_wallet_id
       }) do
    %{
      status: "PENDING",
      amount: 0,
      description: description,
      source: String.to_integer(sender_wallet_id),
      recipient: String.to_integer(recipient_wallet_id)
    }
  end

  defp is_transaction_amount_format_valid?(%{
         amount: amount,
         description: _description,
         sender_wallet_id: _sender_wallet_id,
         recipient_wallet_id: _recipient_wallet_id
       }) do
    String.match?(amount, ~r/^\d{2},\d{2}$/)
  end

  defp parse_amount(transaction_amount) do
    String.replace(transaction_amount, ",", "")
    |> String.to_integer()
  end
end
