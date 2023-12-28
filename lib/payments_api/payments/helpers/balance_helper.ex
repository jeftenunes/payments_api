defmodule PaymentsApi.Payments.Helpers.BalanceHelper do
  alias PaymentsApi.Payments.Parsers.MoneyParser

  def sum_balance_amount(transaction, acc) when transaction.type === "CREDIT" do
    parsed_amount = build_amount_value(transaction.amount)

    acc + parsed_amount
  end

  def sum_balance_amount(transaction, acc) when transaction.type === "DEBIT" do
    parsed_amount = build_amount_value(transaction.amount)

    acc - parsed_amount
  end

  def parse_amount(amount) do
    amount
    |> MoneyParser.maybe_parse_amount_from_integer()
  end

  defp build_amount_value(amount_from_db) do
    amount_from_db
    |> MoneyParser.maybe_parse_amount_from_integer()
  end
end
