defmodule PaymentsApi.Payments.Transactions.TransactionValidator do
  alias PaymentsApi.Repo
  alias PaymentsApi.Payments.Helpers.BalanceHelper
  alias PaymentsApi.Payments.Transactions.Transaction

  def validate_transaction(nil), do: []

  def validate_transaction(transaction) do
    parsed_amount = BalanceHelper.parse_amount(transaction.amount)

    history =
      transaction.wallet_id
      |> Transaction.build_find_transaction_history_for_wallet_qry()
      |> Repo.all()

    validate_source_wallet_balance(
      calculate_balance_for_wallet(history),
      transaction,
      parsed_amount
    )
  end

  ## helpers

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
