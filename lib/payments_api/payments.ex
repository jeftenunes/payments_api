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
    Parsers.MoneyParser,
    TransactionValidator,
    Helpers.BalanceHelper
  }

  def get_transaction(id), do: Repo.get(Transaction, id)

  def create_transaction(%{} = attrs, transaction_status \\ "PENDING") do
    attrs = Map.put_new(attrs, :description, nil)
    attrs = Map.put_new(attrs, :status, transaction_status)

    source_id = String.to_integer(attrs.source)
    recipient_id = String.to_integer(attrs.recipient)

    with %{source: source, recipient: recipient} = wallets <-
           retrieve_transaction_wallets(source_id, recipient_id),
         exchange_rate when is_float(exchange_rate) <-
           retrieve_exchange_rate(source.currency, recipient.currency) do
      initial_debit_transaction_state = build_initial_transaction_state(attrs, source_id, "DEBIT")

      initial_credit_transaction_state =
        build_initial_transaction_state(attrs, recipient_id, "CREDIT")

      {:valid, credit_transaction_amount} =
        MoneyParser.maybe_parse_amount_from_string(attrs.amount)

      {:valid, credit_transaction_amount} =
        (MoneyParser.maybe_parse_amount_from_integer(credit_transaction_amount) * exchange_rate)
        |> :erlang.float_to_binary(decimals: 2)
        |> MoneyParser.maybe_parse_amount_from_string()

      {:valid, parsed_exchange_rate} =
        ExchangeRate.parse_exchange_rate_to_db(to_string(exchange_rate))

      initial_debit_transaction_state =
        Map.put(
          initial_debit_transaction_state,
          :exchange_rate,
          100
        )

      initial_credit_transaction_state =
        Map.put(
          initial_credit_transaction_state,
          :exchange_rate,
          parsed_exchange_rate
        )

      with {:valid, transaction_amount} <-
             MoneyParser.maybe_parse_amount_from_string(attrs.amount) do
        initial_debit_transaction_state =
          Map.put(
            initial_debit_transaction_state,
            :amount,
            transaction_amount
          )

        initial_credit_transaction_state =
          Map.put(
            initial_credit_transaction_state,
            :amount,
            credit_transaction_amount
          )

        {:ok, debit_op_result} =
          %Transaction{}
          |> Transaction.changeset(initial_debit_transaction_state)
          |> Repo.insert()

        initial_credit_transaction_state =
          Map.put(
            initial_credit_transaction_state,
            :origin_transaction_id,
            debit_op_result.id
          )

        credit_op_result =
          %Transaction{}
          |> Transaction.changeset(initial_credit_transaction_state)
          |> Repo.insert()

        map_response({credit_op_result, wallets})
      else
        {:invalid, errors} ->
          errors
      end
    else
      {:error, _message} ->
        [
          "Error retrieving exchange rates. You still can transfer money between same currency wallets."
        ]

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
    |> Enum.reduce(%{}, fn validation_result, acc ->
      {debit_processed, credit_processed} =
        case validation_result do
          {:valid, transaction} ->
            {:ok, debit} = update_transaction_status(transaction, "PROCESSED")
            {:ok, credit} = process_credit_transaction(transaction.id)
            IO.inspect(debit)
            IO.inspect(credit)
            {debit, credit}

          {:invalid, transaction} ->
            update_transaction_status(transaction, "REFUSED")
        end

      acc = Map.put(acc, debit_processed.id, debit_processed)
      acc = Map.put(acc, credit_processed.id, credit_processed)

      acc
    end)
  end

  def retrieve_total_worth_for_user(%{id: id, currency: currency} = params) do
    with true <- Currencies.is_supported?(currency) do
      Transaction.build_find_transaction_history_for_user_qry(id)
      |> Repo.all()
      |> aggregate_user_transaction_summary(params)
    else
      _ -> ["Currencies not supported"]
    end
  end

  def get_user_by(%{id: id}) do
    User.find_users(id)
    |> Repo.all()
    |> build_users_list()
    |> List.first()
  end

  def get_user_by(%{email: email}) do
    User.find_user_by_email(email)
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
          load_wallet(wallet.id)

        {:ok, wallet}

      {false, _} ->
        ["User does not exist"]

      {_, false} ->
        ["Currencies not supported"]
    end
  end

  def find_user_by_wallet_id_qry(wallet_id) do
    Wallet.build_find_user_by_wallet_id_qry(wallet_id)
    |> Repo.one!()
  end

  ## helpers
  defp process_credit_transaction(origin_transaction_id) do
    Transaction.build_find_transaction_history_by_origin_qry(origin_transaction_id)
    |> Repo.one!()
    |> Transaction.changeset(%{status: "PROCESSED"})
    |> Repo.update()
  end

  defp load_wallet(wallet_id) do
    {:valid, parsed_exchange_rate} =
      ExchangeRate.parse_exchange_rate_to_db("1.0")

    {:valid, initial_amount} = MoneyParser.maybe_parse_amount_from_string("100")

    first_transaction = %{
      type: "CREDIT",
      status: "PROCESSED",
      wallet_id: wallet_id,
      amount: initial_amount,
      description: "FIRST LOAD",
      exchange_rate: parsed_exchange_rate
    }

    %Transaction{}
    |> Transaction.changeset(first_transaction)
    |> Repo.insert()
  end

  defp aggregate_user_transaction_summary([], %{id: user_id, currency: currency}),
    do: %{user_id: user_id, currency: currency, total_worth: 0, exchange_rate: 0}

  defp aggregate_user_transaction_summary(wallets_transactions, %{
         id: _user_id,
         currency: currency
       }) do
    user_total_worth =
      wallets_transactions
      |> Enum.group_by(fn transaction -> transaction.wallet_id end)
      |> Enum.reduce([], fn {_wallet_id, transactions}, acc ->
        acc =
          [
            Enum.reduce(transactions, %{amount: 0}, fn transaction, transaction_acc ->
              %{
                user_id: transaction.user_id,
                currency: transaction.currency,
                wallet_id: transaction.wallet_id,
                amount:
                  BalanceHelper.sum_balance_amount(
                    transaction,
                    transaction_acc.amount
                  )
              }
            end)
            | acc
          ]

        acc
      end)
      |> Enum.reduce(
        %{currency: currency, user_id: nil, total_worth: 0, exchange_rate: 0},
        fn summary, acc ->
          case retrieve_exchange_rate(summary.currency, currency) do
            {:error, message} ->
              Map.put(acc, :in_error, message)

            exchange_rate when is_float(exchange_rate) ->
              %{
                acc
                | user_id: summary.user_id,
                  exchange_rate: exchange_rate,
                  total_worth: exchange_rate * summary.amount + acc.total_worth
              }
          end
        end
      )

    build_user_total_worth(user_total_worth)
  end

  defp build_user_total_worth(
         %{
           user_id: _user_id,
           exchange_rate: _exchange_rate,
           total_worth: _total_worth,
           in_error: message
         } = _user_total_worth
       ) do
    [message]
  end

  defp build_user_total_worth(
         %{
           user_id: _user_id,
           exchange_rate: _exchange_rate,
           total_worth: _total_worth
         } = user_total_worth
       ) do
    %{
      user_total_worth
      | total_worth: :erlang.float_to_binary(user_total_worth.total_worth, decimals: 2)
    }
  end

  defp retrieve_exchange_rate(from_currency, to_currency) when from_currency == to_currency,
    do: 1.0

  defp retrieve_exchange_rate(from_currency, to_currency) do
    case ExchangeRate.retrieve_exchange_rate(from_currency, to_currency) do
      {:error, message} ->
        {:error, message}

      exchange_rate when is_binary(exchange_rate) ->
        String.to_float(exchange_rate)
    end
  end

  defp build_wallet_initial_state(attrs) do
    %Wallet{currency: attrs.currency, user_id: String.to_integer(attrs.user_id)}
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

  defp build_initial_transaction_state(
         %{
           status: status,
           description: description
         },
         wallet_id,
         type
       ) do
    %{
      type: type,
      status: status,
      wallet_id: wallet_id,
      description: description
    }
  end

  defp retrieve_transaction_wallets(source_id, recipient_id) do
    Wallet.build_fetch_wallets_qry(source_id, recipient_id)
    |> Repo.one()
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
