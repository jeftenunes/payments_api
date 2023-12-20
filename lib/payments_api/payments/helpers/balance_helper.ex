defmodule PaymentsApi.Payments.Helpers.BalanceHelper do
  def sum_balance_amount(transaction, wallet_id, acc) when transaction.recipient == wallet_id do
    parsed_amount = build_amount_value(transaction.amount)

    acc + parsed_amount
  end

  def sum_balance_amount(transaction, wallet_id, acc) when transaction.recipient != wallet_id do
    parsed_amount = build_amount_value(transaction.amount)

    acc - parsed_amount
  end

  def parse_amount(amount) do
    amount |> Integer.to_string() |> parse_amount_from_db()
  end

  #### CRIAR UM PARSER DE VALORES Q FUNCIONE
  defp parse_amount_from_db(str_amount) when byte_size(str_amount) < 3 do
    val =
      "#{String.slice(str_amount, 0, 1)},#{String.slice(str_amount, -2, 2)}"

    val
  end

  defp parse_amount_from_db(str_amount) do
    val =
      "#{String.slice(str_amount, 0, String.length(str_amount) - 2)},#{String.slice(str_amount, -2, 2)}"
      |> String.to_float()

    val
  end

  defp build_amount_value(amount_from_db) do
    amount_from_db
    |> to_string()
    |> parse_amount_from_db()
  end
end
