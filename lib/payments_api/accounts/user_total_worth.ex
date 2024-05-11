defmodule PaymentsApi.Accounts.UserTotalWorth do
  alias EctoShorts.Actions
  alias PaymentsApi.Currencies
  alias PaymentsApi.Accounts.Wallet

  def retrieve_user_total_worth(params) do
    retrieve_transactions_for_user(params)
  end

  defp retrieve_transactions_for_user(params) do
    usr_transactions =
      Actions.all(Wallet.find_transaction_history_for_user_qry(params.user_id))

    converted_transactions = apply_exchange_rate(usr_transactions, params.currency)

    IO.inspect(converted_transactions)

    user_total_worth_amount =
      Enum.reduce(converted_transactions, 0, fn t, acc -> sum_amount_of(t, acc) end)

    %{
      user_id: params.user_id,
      currency: params.currency,
      total_worth: "#{user_total_worth_amount}"
    }
  end

  defp apply_exchange_rate(transactions, to_currency) do
    Enum.map(transactions, fn transaction ->
      %{exchange_rate: exchange_rate} =
        Currencies.retrieve_rate_for_currency(transaction.currency, to_currency)

      %{
        type: transaction.type,
        to_currency: to_currency,
        exchange_rate: exchange_rate,
        from_currency: transaction.currency,
        amount: transaction.amount / 100 * exchange_rate
      }
    end)
  end

  defp sum_amount_of(transaction, acc) when transaction.type === "CREDIT",
    do: acc + transaction.amount

  defp sum_amount_of(transaction, acc) when transaction.type === "DEBIT",
    do: acc - transaction.amount
end
