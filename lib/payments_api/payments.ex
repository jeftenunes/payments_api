defmodule PaymentsApi.Payments do
  @moduledoc """
  The Payments context.
  """

  import Ecto.Query, warn: false

  alias PaymentsApi.Payments.TransactionValidator
  alias PaymentsApi.Repo

  alias PaymentsApi.Payments.{
    User,
    Wallet,
    Currencies,
    Transaction,
    ExchangeRate,
    TransactionValidator,
    Helpers.BalanceHelper
  }

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
  def create_transaction(%{} = attrs, transaction_status \\ "PENDING") do
    ## buscar as carteiras e a rate

    attrs = Map.put_new(attrs, :description, nil)
    attrs = Map.put_new(attrs, :status, transaction_status)

    source_id = String.to_integer(attrs.source)
    recipient_id = String.to_integer(attrs.recipient)

    with {:ok, initial_transaction_state} <- build_initial_transaction_state(attrs),
         %{source: source, recipient: recipient} = summary <-
           retrieve_transaction_summary(source_id, recipient_id) do
      exchange_rate = retrieve_exchange_rate(source.currency, recipient.currency)

      initial_transaction_state =
        Map.put(
          initial_transaction_state,
          :exchange_rate,
          ExchangeRate.parse_exchange_rate_to_db(to_string(exchange_rate))
        )

      op_result =
        %Transaction{}
        |> Transaction.changeset(initial_transaction_state)
        |> Repo.insert()

      map_response({op_result, summary})
    else
      errors when is_list(errors) ->
        errors

      nil ->
        ["source or recipient wallet does not exist"]
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
    retrieve_transactions_to_process()
    |> Enum.map(&TransactionValidator.maybe_validate_transaction(&1))
    |> Enum.each(fn validation_result ->
      case validation_result do
        {:valid, transaction} ->
          update_transaction_status(transaction, "PROCESSED")

        {:invalid, transaction} ->
          update_transaction_status(transaction, "REFUSED")
      end
    end)
  end

  def retrieve_total_worth_for_user(%{id: id, currency: _currency} = params) do
    Transaction.build_find_transaction_history_for_user_qry(id)
    |> Repo.all()
    |> aggregate_user_transaction_summary(params)
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
    case {user_exists(String.to_integer(user_id)), Currencies.is_supported?(currency)} do
      {true, true} ->
        {:ok, wallet} =
          build_wallet_initial_state(attrs)
          |> Wallet.changeset(attrs)
          |> Repo.insert()

        {:ok, _} =
          create_transaction(
            %{
              amount: "10000",
              source: to_string(wallet.id),
              recipient: to_string(wallet.id),
              description: "FIRST LOAD"
            },
            "PROCESSED"
          )

        {:ok, wallet}

      {false, _} ->
        ["User does not exist"]

      {_, false} ->
        ["Currencies not supported"]
    end
  end

  ## helpers
  defp aggregate_user_transaction_summary([], %{id: user_id, currency: currency}),
    do: %{user_id: user_id, currency: currency, total_worth: 0}

  defp aggregate_user_transaction_summary(wallets_transactions, %{
         id: _user_id,
         currency: currency
       }) do
    wallets_transactions
    |> Enum.group_by(fn transaction -> transaction.wallet_id end)
    |> Enum.reduce([], fn {wallet_id, transactions}, acc ->
      acc =
        [
          Enum.reduce(transactions, %{amount: 0}, fn transaction, transaction_acc ->
            %{
              currency: transaction.currency,
              user_id: transaction.user_id,
              wallet_id: transaction.wallet_id,
              amount:
                BalanceHelper.sum_balance_amount(
                  transaction,
                  wallet_id,
                  transaction_acc.amount
                )
            }
          end)
          | acc
        ]

      acc
    end)
    |> Enum.map(fn transaction ->
      %{
        currency: transaction.currency,
        user_id: transaction.user_id,
        wallet_id: transaction.wallet_id,
        amount: transaction.amount
      }
    end)
    |> Enum.reduce(%{currency: currency, user_id: nil, total_worth: 0}, fn summary, acc ->
      exchange_rate = retrieve_exchange_rate(summary.currency, currency)

      %{
        acc
        | user_id: summary.user_id,
          total_worth: summary.amount * exchange_rate + acc.total_worth
      }
    end)
  end

  defp retrieve_exchange_rate(from_currency, to_currency) when from_currency == to_currency,
    do: 1

  defp retrieve_exchange_rate(from_currency, to_currency) do
    ExchangeRate.retrieve_exchange_rate(from_currency, to_currency).exchange_rate
    |> ExchangeRate.parse_exchange_rate()
  end

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
         status: status,
         recipient: recipient,
         description: description
       }) do
    case maybe_parse_amount(amount) do
      {:valid, parsed_amount} ->
        {:ok,
         %{
           status: status,
           amount: parsed_amount,
           description: description,
           source: String.to_integer(source),
           recipient: String.to_integer(recipient)
         }}

      {:invalid, _} ->
        ["transaction amount incorrectly formatted."]
    end
  end

  defp retrieve_transaction_summary(source_id, recipient_id) do
    Wallet.build_fetch_wallets_qry(source_id, recipient_id)
    |> Repo.one()
  end

  defp maybe_parse_amount(transaction_amount) do
    cond do
      String.match?(transaction_amount, ~r/^0,\d{1,2}$/) ->
        parsed =
          String.replace(transaction_amount, ",", "")
          |> String.slice(1..-1)
          |> String.pad_trailing(2, "0")
          |> String.to_integer()

        {:valid, parsed}

      String.match?(transaction_amount, ~r/^\d+,\d{1,2}$/) ->
        parsed =
          String.replace(transaction_amount, ",", "")
          |> String.pad_trailing(3, "0")
          |> String.to_integer()

        {:valid, parsed}

      String.match?(transaction_amount, ~r/^0.\d{1,2}$/) ->
        parsed =
          String.replace(transaction_amount, ".", "")
          |> String.slice(1..-1)
          |> String.pad_trailing(2, "0")
          |> String.to_integer()

        IO.inspect(parsed)
        {:valid, parsed}

      String.match?(transaction_amount, ~r/^\d+.\d{1,2}$/) ->
        parsed =
          String.replace(transaction_amount, ",", "")
          |> String.pad_trailing(3, "0")
          |> String.to_integer()

        {:valid, parsed}

      String.match?(transaction_amount, ~r/^\d+/) ->
        {:valid, (transaction_amount |> String.to_integer()) * 100}

      true ->
        {:invalid, nil}
    end
  end

  defp map_response({
         {:ok, transaction} = _op_result,
         %{source: source, recipient: recipient} = _summary
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
