defmodule PaymentsApi.UserTotalWorth do
  alias PaymentsApi.Repo
  alias PaymentsApi.UserTotalWorth.Store

  alias PaymentsApi.Payments.{
    Currencies,
    ExchangeRate,
    Helpers.BalanceHelper,
    Transactions.Transaction
  }

  def track_user_total_worth(user_id) do
    case Store.get_user_by_worth_summary(user_id) do
      nil ->
        total_worth =
          retrieve_total_worth_for_user(%{id: user_id, currency: nil})

        Store.save_user_worth_summary(total_worth)
        {:ok, total_worth}

      total_worth ->
        {:ok, total_worth}
    end
  end

  def untrack_user_total_worth(user_id) do
    Store.remove_user_worth_summary(user_id)
  end

  def retrieve_total_worth_for_user(%{id: id, currency: currency} = params) do
    case Currencies.supported?(currency) do
      true ->
        id
        |> Transaction.build_find_transaction_history_for_user_qry()
        |> Repo.all()
        |> aggregate_user_transaction_summary(params)

      _ ->
        ["Currencies not supported"]
    end
  end

  ## helpers

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
end
