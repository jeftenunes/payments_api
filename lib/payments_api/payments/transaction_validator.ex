defmodule PaymentsApi.Payments.TransactionValidator do
  alias PaymentsApi.Payments.{Transaction, Helpers.BalanceHelper}
  alias PaymentsApi.Repo

  @minimum_transaction_amount Application.compile_env(:payments_api, :minimum_transaction_amount)

  def maybe_validate_transaction(transaction) do
    do_validate_transaction(transaction)
  end

  ## helpers
  defp do_validate_transaction(nil), do: []

  defp do_validate_transaction(transaction) do
    parsed_amount = BalanceHelper.parse_amount(transaction.amount)

    Transaction.build_find_transaction_history_for_wallet_qry(transaction.source)
    |> Repo.all()
    |> calculate_balance_for_wallet(transaction.source)
    |> validate_source_wallet_balance(transaction, parsed_amount)
  end

  defp calculate_balance_for_wallet(transactions, wallet_id) when is_list(transactions) do
    Enum.reduce(transactions, 0, fn val, acc ->
      BalanceHelper.sum_balance_amount(val, wallet_id, acc)
    end)
  end

  defp validate_source_wallet_balance(wallet_balance, transaction, parsed_amount)
       when wallet_balance >= parsed_amount,
       do: {:valid, transaction}

  defp validate_source_wallet_balance(wallet_balance, transaction, parsed_amount)
       when wallet_balance < parsed_amount,
       do: {:invalid, transaction}
end
