defmodule PaymentsApi.Accounts.UserTotalWorth do
  alias EctoShorts.Actions
  alias PaymentsApi.Currencies
  alias PaymentsApi.Accounts.Wallet

  def retrieve_user_total_worth(params) do
    usr_transactions =
      Actions.all(Wallet.find_transaction_history_for_user_qry(params.user_id))

    user_total_worth_amount = calculate_total_worth(usr_transactions, params.currency)

    %{
      user_id: params.user_id,
      currency: params.currency,
      total_worth: "#{user_total_worth_amount / 10000}"
    }
  end

  def calculate_balance_for_wallet(wallet_id) do
    wallet_id
    |> Wallet.find_transaction_history_for_wallet_qry()
    |> Actions.all()
    |> Enum.reduce(0, fn transaction, acc ->
      sum_amount_of(
        %{type: transaction.type, amount: transaction.amount * transaction.exchange_rate},
        acc
      )
    end)
  end

  defp calculate_total_worth(transactions, currency) do
    converted_transactions = apply_exchange_rate(transactions, currency)

    Enum.reduce(converted_transactions, 0, fn t, acc ->
      sum_amount_of(t, acc)
    end)
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
        amount: transaction.amount * exchange_rate * 100
      }
    end)
  end

  defp sum_amount_of(%{type: type} = transaction, acc) when type === "CREDIT",
    do: acc + transaction.amount

  defp sum_amount_of(%{type: type} = transaction, acc) when type === "DEBIT",
    do: acc - transaction.amount
end
