defmodule PaymentsApi.Payments.TransactionValidator do
  alias PaymentsApi.Payments.{Transaction, Helpers.BalanceHelper}
  alias PaymentsApi.Repo

  def maybe_validate_transaction(transaction) do
    do_validate_transaction(transaction)
  end

  ## helpers
  defp do_validate_transaction(nil), do: []

  defp do_validate_transaction(transaction) do
    parsed_amount = BalanceHelper.parse_amount(transaction.amount)

    Transaction.build_find_transaction_history_for_wallet_qry(transaction.wallet_id)
    |> Repo.all()
    |> calculate_balance_for_wallet()
    |> validate_source_wallet_balance(transaction, parsed_amount)
  end

  defp calculate_balance_for_wallet(transactions) when is_list(transactions) do
    Enum.reduce(transactions, 0, fn val, acc ->
      BalanceHelper.sum_balance_amount(val, acc)
    end)
  end

  defp validate_source_wallet_balance(wallet_balance, transaction, parsed_amount)
       when wallet_balance >= parsed_amount,
       do: {:valid, transaction}

  defp validate_source_wallet_balance(wallet_balance, transaction, parsed_amount)
       when wallet_balance < parsed_amount,
       do: {:invalid, transaction}
end
