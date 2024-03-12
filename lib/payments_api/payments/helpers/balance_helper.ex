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
    MoneyParser.maybe_parse_amount_from_integer(amount)
  end

  defp build_amount_value(amount_from_db) do
    MoneyParser.maybe_parse_amount_from_integer(amount_from_db)
  end
end
