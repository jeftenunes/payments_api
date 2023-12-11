defmodule PaymentsApi.Payments.TransactionValidator do
  alias PaymentsApi.Payments.{Transaction, BalanceHelper}
  alias PaymentsApi.Repo

  def maybe_validate_transaction(transaction) do
    do_validate_transaction(transaction)
  end

  ## helpers
  defp do_validate_transaction(nil), do: []

  defp do_validate_transaction(transaction) do
    Transaction.build_find_transaction_history_for_wallet_qry(transaction.source)
    |> Repo.all()
    |> calculate_balance_for_wallet(transaction.source)
    |> validate_source_wallet_balance(transaction)
  end

  defp calculate_balance_for_wallet(transactions, wallet_id) when is_list(transactions) do
    Enum.reduce(transactions, 0, fn val, acc ->
      BalanceHelper.sum_balance_amount(val, wallet_id, acc)
    end)
  end

  defp validate_source_wallet_balance(wallet_balance, transaction)
       when wallet_balance >= transaction.amount,
       do: {:valid, transaction}

  defp validate_source_wallet_balance(wallet_balance, transaction)
       when wallet_balance < transaction.amount,
       do: {:invalid, "INSUFFICIENT_BALANCE", transaction}
end
