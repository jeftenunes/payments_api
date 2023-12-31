defmodule PaymentsApi.Payments.TransactionHelper do
  def sum_balance_amount(transaction, wallet_id, acc) when transaction.recipient == wallet_id do
    parsed_amount = build_amount_value(transaction.amount)
    # parsed_acc = parse_acc(acc)

    acc + parsed_amount
  end

  def sum_balance_amount(transaction, wallet_id, acc) when transaction.recipient != wallet_id do
    parsed_amount = build_amount_value(transaction.amount)
    # parsed_acc = parse_acc(acc)

    acc - parsed_amount
  end

  defp parse_acc(acc) when acc == 0, do: 0.0

  defp parse_acc(acc) do
    {parsed, _} = Float.parse(acc)
    parsed
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
      "#{String.slice(str_amount, 0, String.length(str_amount) - 2)}.#{String.slice(str_amount, -2, 2)}"
      |> Float.parse()

    val
  end
end
