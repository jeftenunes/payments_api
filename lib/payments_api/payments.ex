defmodule PaymentsApi.Payments do
  alias PaymentsApi.Repo
  alias EctoShorts.Actions
  alias PaymentsApi.Payments.Transaction
  alias PaymentsApi.{Accounts, Currencies}

  def send_money(%{} = attrs) do
    source_id = String.to_integer(attrs.source)
    recipient_id = String.to_integer(attrs.recipient)

    with {:ok, transaction_amount} <- maybe_parse_amount_from_params_to_integer(attrs.amount),
         {:ok, {source, recipient}} <-
           retrieve_wallets_involved_in_transaction(source_id, recipient_id),
         :ok <- validate_source_wallet_balance(source_id, transaction_amount),
         %{exchange_rate: exchange_rate} <-
           retrieve_rate_for_currency(source.currency, recipient.currency) do
      transaction_amount_rate_applied = transaction_amount * exchange_rate / 100

      debit_transaction =
        build_transaction(%{
          type: "DEBIT",
          exchange_rate: 1,
          status: "PROCESSED",
          wallet_id: source.id,
          amount: transaction_amount,
          description: attrs.description
        })

      credit_transaction =
        build_transaction(%{
          type: "CREDIT",
          status: "PROCESSED",
          wallet_id: recipient.id,
          amount: transaction_amount,
          exchange_rate: exchange_rate,
          description: attrs.description
        })

      op_result =
        {:ok, _credit_transaction} =
        Repo.transaction(fn ->
          _debit_transaction_op = Actions.create(Transaction, debit_transaction)
          {:ok, credit_transaction} = Actions.create(Transaction, credit_transaction)

          %{
            id: credit_transaction.id,
            exchange_rate: exchange_rate,
            from_currency: source.currency,
            to_currency: recipient.currency,
            amount: transaction_amount_rate_applied,
            description: credit_transaction.description
          }
        end)

      Accounts.publish_user_total_worth_updates(source.user_id)
      Accounts.publish_user_total_worth_updates(recipient.user_id)

      op_result
    end
  end

  defp retrieve_wallets_involved_in_transaction(source_id, recipient_id) do
    case {Accounts.get_wallet_by(%{id: source_id}), Accounts.get_wallet_by(%{id: recipient_id})} do
      {{:ok, source}, {:ok, recipient}} ->
        {:ok, {source, recipient}}

      {{:error, message}, _} ->
        {:error, "source: #{message}"}

      {_, {:error, message}} ->
        {:error, "recipient: #{message}"}
    end
  end

  defp validate_source_wallet_balance(source_id, transaction_amount) do
    source_wallet_balance = Accounts.calculate_balance_for_wallet(source_id)

    case source_wallet_balance > transaction_amount do
      true ->
        :ok

      false ->
        {:error, "insufficient balance"}
    end
  end

  defp build_transaction(%{} = params) do
    %{
      type: params.type,
      amount: params.amount,
      status: params.status,
      wallet_id: params.wallet_id,
      description: params.description,
      exchange_rate: params.exchange_rate
    }
  end

  defp maybe_parse_amount_from_params_to_integer(amount_str) do
    case Integer.parse(amount_str) do
      :error -> {:error, "invalid amount"}
      {amount, _} -> {:ok, amount}
    end
  end

  defdelegate retrieve_rate_for_currency(from_currency, to_currency), to: Currencies
end
