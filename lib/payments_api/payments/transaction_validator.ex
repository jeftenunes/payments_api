defmodule PaymentsApi.Payments.TransactionValidator do
  require IEx
  alias PaymentsApi.Payments.Transaction
  alias PaymentsApi.Repo

  def validate_transaction(transaction) do
    processed_transactions_for_wallet =
      Transaction.find_transaction_history_for_wallet(transaction.source)
      |> Repo.all()

    wallet_balance =
      calculate_balance_for_wallet(processed_transactions_for_wallet, transaction.source)

    validate_source_wallet_balance(transaction, wallet_balance)
  end

  ## helpers
  defp calculate_balance_for_wallet(transactions, wallet_id) when is_list(transactions) do
    Enum.reduce(transactions, 0, fn val, acc ->
      if val.recipient == wallet_id do
        acc + val.amount
      else
        acc - val.amount
      end
    end)
  end

  defp validate_source_wallet_balance(transaction, wallet_balance)
       when wallet_balance >= transaction.amount,
       do: {:valid, transaction}

  defp validate_source_wallet_balance(transaction, wallet_balance)
       when wallet_balance < transaction.amount,
       do: {:invalid, "INSUFFICIENT_BALANCE", transaction}
end
