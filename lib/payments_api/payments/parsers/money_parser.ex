defmodule PaymentsApi.Payments.Parsers.MoneyParser do
  @spec maybe_parse_amount_from_string(String.t()) :: {:valid, integer()} | {:invalid, nil}
  def maybe_parse_amount_from_string(amount) do
    cond do
      String.match?(amount, ~r/^\d+,\d{1,2}$/) ->
        parsed =
          amount
          |> String.replace(",", "")
          |> String.pad_trailing(3, "0")
          |> String.to_integer()

        {:valid, parsed}

      String.match?(amount, ~r/^\d+$/) ->
        prepared_str =
          "#{String.replace(amount, ".", "")}00"

        parsed = String.to_integer(prepared_str)

        {:valid, parsed}

      String.match?(amount, ~r/^\d+\.\d{1,2}$/) ->
        parsed =
          amount
          |> String.replace(".", "")
          |> String.pad_trailing(3, "0")
          |> String.to_integer()

        {:valid, parsed}

      true ->
        {:invalid, ["cannot parse amount | #{amount}"]}
    end
  end

  def maybe_parse_amount_from_integer(amount) do
    amount
    |> Integer.to_string()
    |> do_maybe_parse_amount_from_integer()
  end

  defp do_maybe_parse_amount_from_integer(str_amount) when byte_size(str_amount) < 3 do
    {whole_part, decimal} =
      str_amount
      |> String.pad_leading(3, "0")
      |> String.split_at(1)

    String.to_float("#{whole_part}.#{decimal}")
  end

  defp do_maybe_parse_amount_from_integer(str_amount) do
    val =
      String.to_float(
        "#{String.slice(str_amount, 0, String.length(str_amount) - 2)}.#{String.slice(str_amount, -2, 2)}"
      )

    val
  end
end
