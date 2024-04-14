defmodule PaymentsApi.Payments.Transactions do
  alias PaymentsApi.Repo
  alias PaymentsApi.Payments.Transactions.{Transaction, TransactionValidator}

  alias PaymentsApi.Payments.{
    Wallets,
    ExchangeRate,
    Parsers.MoneyParser,
    Transactions.Transaction
  }

  def get_transaction(id), do: Repo.get(Transaction, id)

  def create_transaction(%{} = attrs, transaction_status \\ "PENDING") do
    attrs = Map.put_new(attrs, :description, nil)
    attrs = Map.put_new(attrs, :status, transaction_status)

    source_id = String.to_integer(attrs.source)
    recipient_id = String.to_integer(attrs.recipient)

    with %{source: source, recipient: recipient} = wallets <-
           Wallets.retrieve_transaction_wallets(source_id, recipient_id),
         exchange_rate when is_float(exchange_rate) <-
           retrieve_exchange_rate(recipient.currency, source.currency) do
      initial_debit_transaction_state = build_initial_transaction_state(attrs, source_id, "DEBIT")

      initial_credit_transaction_state =
        build_initial_transaction_state(attrs, recipient_id, "CREDIT")

      case MoneyParser.maybe_parse_amount_from_string(attrs.amount) do
        {:valid, transaction_amount} ->
          {:valid, credit_transaction_amount} =
            apply_exchange_rate_to_amount(transaction_amount, exchange_rate)

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
            Repo.transaction(fn ->
              %Transaction{}
              |> Transaction.changeset(initial_debit_transaction_state)
              |> Repo.insert!()
            end)

          initial_credit_transaction_state =
            Map.put(
              initial_credit_transaction_state,
              :origin_transaction_id,
              debit_op_result.id
            )

          {:ok, credit_op_result} =
            Repo.transaction(fn ->
              %Transaction{}
              |> Transaction.changeset(initial_credit_transaction_state)
              |> Repo.insert()
            end)

          map_response({credit_op_result, wallets})

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

  def process_transaction do
    retrieve_transactions_to_process()
    |> Enum.map(&TransactionValidator.validate_transaction(&1))
    |> Enum.reduce(%{}, fn validation_result, acc ->
      processing_results =
        case validation_result do
          {:valid, transaction} ->
            {:ok, {debit, credit}} =
              Repo.transaction(fn ->
                {:ok, debit} = update_transaction_status(transaction, "PROCESSED")
                {:ok, credit} = process_credit_transaction(transaction.id)

                {debit, credit}
              end)

            {:processed, {debit, credit}}

          {:invalid, transaction} ->
            update_transaction_status(transaction, "REFUSED")
            {:refused, transaction}
        end

      acc =
        build_payment_processing_result(acc, processing_results)

      acc
    end)
  end

  def update_transaction_status(transaction, new_status) do
    transaction
    |> Transaction.changeset(%{status: new_status})
    |> Repo.update()
  end

  def retrieve_transactions_to_process do
    Repo.all(Transaction.build_retrieve_transactions_to_process_query())
  end

  def load_wallet(wallet_id) do
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

  defp apply_exchange_rate_to_amount(transaction_amount, exchange_rate) do
    rate_applied_amount =
      MoneyParser.parse_amount_from_integer(transaction_amount) *
        exchange_rate

    rate_applied_amount
    |> :erlang.float_to_binary(decimals: 2)
    |> MoneyParser.maybe_parse_amount_from_string()
  end

  defp retrieve_exchange_rate(from_currency, to_currency) when from_currency === to_currency,
    do: 1.0

  defp retrieve_exchange_rate(from_currency, to_currency) do
    case ExchangeRate.retrieve_exchange_rate(from_currency, to_currency) do
      {:error, message} ->
        {:error, message}

      exchange_rate when is_binary(exchange_rate) ->
        String.to_float(exchange_rate)
    end
  end

  defp build_payment_processing_result(acc, {:refused, refused_transaction}) do
    Map.put(acc, refused_transaction.id, refused_transaction)
  end

  defp build_payment_processing_result(acc, {:processed, {debit_processed, credit_processed}}) do
    acc = Map.put(acc, debit_processed.id, debit_processed)
    acc = Map.put(acc, credit_processed.id, credit_processed)

    acc
  end

  defp process_credit_transaction(origin_transaction_id) do
    origin_transaction_id
    |> Transaction.build_find_transaction_history_by_origin_qry()
    |> Repo.one!()
    |> Transaction.changeset(%{status: "PROCESSED"})
    |> Repo.update()
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
