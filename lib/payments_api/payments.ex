defmodule PaymentsApi.Payments do
  @moduledoc """
  The Payments context.
  """

  import Ecto.Query, warn: false

  alias PaymentsApi.Payments.TransactionValidator
  alias PaymentsApi.Repo
  alias PaymentsApiWeb.Resolvers.ErrorsHelper
  alias PaymentsApi.Payments.TransactionMetadata
  alias PaymentsApi.Payments.Currencies.ExchangeRateMonitorServer

  alias PaymentsApi.Payments.{
    User,
    Wallet,
    Transaction,
    Currencies.Currency,
    Currencies.ExchangeRateMonitorServer
  }

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
          source: source,
          amount: _amount,
          recipient: recipient,
          description: _description
        } = attrs
      ) do
    ## buscar as carteiras e a rate
    source_id = String.to_integer(source)
    recipient_id = String.to_integer(recipient)

    with {:ok, initial_transaction_state} <- build_initial_transaction_state(attrs),
         %{source: source, recipient: recipient} = metadata <-
           retrieve_transaction_metadata(source_id, recipient_id) do
      exchange_rate = retrieve_exchange_rate(source.currency, recipient.currency)

      initial_transaction_state =
        Map.put(
          initial_transaction_state,
          :exchange_rate,
          parse_exchange_rate(exchange_rate.exchange_rate)
        )

      op_result =
        %Transaction{}
        |> Transaction.changeset(initial_transaction_state)
        |> Repo.insert()

      map_graphql_response({op_result, metadata})
    else
      {:error, errors} ->
        {:error, errors}

      nil ->
        ErrorsHelper.build_graphql_error([
          "source or recipient wallet does not exist"
        ])
    end
  end

  def get_user(id) do
    User.find_users(id)
    |> Repo.all()
    |> build_users_list()
    |> List.first()
  end

  def user_exists(id),
    do: User.build_exists_qry(id) |> Repo.exists?()

  def list_users(params) do
    User.find_users(params) |> Repo.all() |> build_users_list()
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def list_wallets(params) do
    Wallet.build_find_wallets_by_qry(params) |> Repo.all()
  end

  def get_wallet(id), do: Repo.get!(Wallet, id)

  def create_wallet(%{user_id: user_id, currency: currency} = attrs) do
    case {user_exists(String.to_integer(user_id)), Currency.is_supported?(currency)} do
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

  def update_transaction_status(transaction, new_status) do
    transaction
    |> Transaction.changeset(%{status: new_status})
    |> Repo.update()
  end

  def retrieve_transactions_to_process() do
    Transaction.build_retrieve_transactions_to_process_query()
    |> Repo.all()
  end

  def process_transaction() do
    validation_results =
      retrieve_transactions_to_process()
      |> Enum.map(&TransactionValidator.validate_transaction(&1))

    IO.inspect(validation_results)

    # validations_result = TransactionValidator.validate_transaction(pending_transaction)
    # IO.inspect(validations_result)
    # validations_result

    # transactions =
    #   Transaction.find_transaction_history_for_wallet(transaction.source)
    #   |> Repo.all()

    # case TransactionValidator.validate_pending_transactions(transactions) do
    #   {:valid, validation_results} ->
    #     Enum.each(validation_results, &update_transaction_status(&1.transaction, "PROCESSED"))
    #     :ok

    #   {:invalid, validation_results} ->
    #     Enum.each(validation_results, fn result ->
    #       IO.inspect(
    #         "Transaction rejected: #{result.transaction.id}, reason: #{Enum.join(result.errors, " | ")}"
    #       )

    #       :error
    #     end)
    # end
  end

  ## helpers
  defp build_wallet_initial_state(attrs) do
    %Wallet{balance: 0, currency: attrs.currency, user_id: String.to_integer(attrs.user_id)}
  end

  defp build_users_list(data) do
    wallets =
      data
      |> Enum.map(fn item -> item.wallet end)
      |> Enum.filter(fn w -> w != nil end)

    users =
      data
      |> Enum.map(fn item -> item.user end)
      |> Enum.uniq()

    Enum.map(users, fn user ->
      Map.put(
        user,
        :wallets,
        Enum.filter(wallets, fn wallet -> wallet.user_id == user.id end)
      )
    end)
  end

  defp build_initial_transaction_state(%{
         amount: amount,
         source: source,
         recipient: recipient,
         description: description
       }) do
    case maybe_parse_amount(amount) do
      {:valid, parsed_amount} ->
        {:ok,
         %{
           status: "PENDING",
           amount: parsed_amount,
           description: description,
           source: String.to_integer(source),
           recipient: String.to_integer(recipient)
         }}

      {:invalid, _} ->
        ErrorsHelper.build_graphql_error(["transaction amount bad formatted."])
    end
  end

  defp retrieve_transaction_metadata(source_id, recipient_id) do
    TransactionMetadata.build_fetch_wallets_qry(source_id, recipient_id)
    |> Repo.one()
  end

  defp retrieve_exchange_rate(from_currency, to_currency) do
    exchange_rate = ExchangeRateMonitorServer.get_rate_for_currency(from_currency, to_currency)
    exchange_rate
  end

  defp maybe_parse_amount(transaction_amount) do
    cond do
      String.match?(transaction_amount, ~r/^\d+,\d{2}$/) ->
        {:valid, String.replace(transaction_amount, ",", "") |> String.to_integer()}

      String.match?(transaction_amount, ~r/^\d+.\d{2}$/) ->
        {:valid, String.replace(transaction_amount, ".", "") |> String.to_integer()}

      String.match?(transaction_amount, ~r/^\d+/) ->
        {:valid, transaction_amount |> String.to_integer()}

      true ->
        {:invalid, nil}
    end
  end

  defp parse_exchange_rate(exchange_rate) do
    String.replace(exchange_rate, ".", "")
    |> String.to_integer()
  end

  defp map_graphql_response({
         {:ok, transaction} = _op_result,
         %{source: source, recipient: recipient} = _metadata
       }) do
    {:ok,
     %{
       source: source.id,
       id: transaction.id,
       recipient: recipient.id,
       status: transaction.status,
       amount: transaction.amount,
       from_currency: source.currency,
       to_currency: recipient.currency,
       description: transaction.description,
       exchange_rate: transaction.exchange_rate
     }}
  end
end
