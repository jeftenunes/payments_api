defmodule PaymentsApi.Parsers.MoneyParserTest do
  alias PaymentsApi.Payments.Parsers.MoneyParser

  use ExUnit.Case

  describe "&maybe_parse_amount_from_string/1" do
    test "should parse a string money amount to an integer" do
      assert {:valid, 0} = MoneyParser.maybe_parse_amount_from_string("0")
      assert {:valid, 10} = MoneyParser.maybe_parse_amount_from_string("0.1")
      assert {:valid, 320} = MoneyParser.maybe_parse_amount_from_string("3.20")
      assert {:valid, 100} = MoneyParser.maybe_parse_amount_from_string("1.00")
      assert {:valid, 1000} = MoneyParser.maybe_parse_amount_from_string("10.00")

      assert {:valid, 10} = MoneyParser.maybe_parse_amount_from_string("0,1")
      assert {:valid, 320} = MoneyParser.maybe_parse_amount_from_string("3,20")
      assert {:valid, 100} = MoneyParser.maybe_parse_amount_from_string("1,00")
      assert {:valid, 1000} = MoneyParser.maybe_parse_amount_from_string("10,00")

      assert {:valid, 100} = MoneyParser.maybe_parse_amount_from_string("1")
      assert {:valid, 300} = MoneyParser.maybe_parse_amount_from_string("3")
      assert {:valid, 1000} = MoneyParser.maybe_parse_amount_from_string("10")
    end

    test "should not parse an invalid value" do
      assert {:invalid, ["cannot parse amount | test"]} =
               MoneyParser.maybe_parse_amount_from_string("test")

      assert {:invalid, ["cannot parse amount | abc"]} =
               MoneyParser.maybe_parse_amount_from_string("abc")

      assert {:invalid, ["cannot parse amount | 3;2"]} =
               MoneyParser.maybe_parse_amount_from_string("3;2")
    end
  end
end
