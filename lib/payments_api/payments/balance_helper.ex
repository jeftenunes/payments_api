defmodule PaymentsApi.Payments.BalanceHelper do
  def sum_balance_amount(transaction, wallet_id, acc) when transaction.recipient == wallet_id do
    parsed_amount = build_amount_value(transaction.amount)

    acc + parsed_amount
  end

  def sum_balance_amount(transaction, wallet_id, acc) when transaction.recipient != wallet_id do
    parsed_amount = build_amount_value(transaction.amount)

    acc - parsed_amount
  end

  defp build_amount_value(amount_from_db) do
    amount_from_db
    |> to_string()
    |> parse_amount_from_db()
  end

  defp parse_amount_from_db(str_amount) when byte_size(str_amount) < 3 do
    {val, _} = str_amount |> Float.parse()
    val
  end

  defp parse_amount_from_db(str_amount) do
    {val, _} =
      "#{String.slice(str_amount, 0, String.length(str_amount) - 2)},#{String.slice(str_amount, -2, 2)}"
      |> Float.parse()
    val
  end
end
