defmodule PaymentsApi.PaymentsHelpers do
  @moduledoc false
  def mock_exchange_rate_by_currency({to_currency, from_currency} = _currencies) do
    case {to_currency, from_currency} do
      {:USD, :BRL} -> value({:USD, :BRL}, 1)
      {:BRL, :USD} -> value({:BRL, :USD}, 1)
      {:USD, :CAD} -> value({:USD, :CAD}, 1)
      {:CAD, :USD} -> value({:CAD, :USD}, 1)
      {:BRL, :CAD} -> value({:BRL, :CAD}, 1)
      {:CAD, :BRL} -> value({:CAD, :BRL}, 1)
    end
  end

  def mock_exchange_rate_by_currency_with_variation(
        {to_currency, from_currency} = _currencies,
        variation
      ) do
    case {to_currency, from_currency} do
      {:USD, :BRL} -> value({:USD, :BRL}, variation)
      {:BRL, :USD} -> value({:BRL, :USD}, variation)
      {:USD, :CAD} -> value({:USD, :CAD}, variation)
      {:CAD, :USD} -> value({:CAD, :USD}, variation)
      {:BRL, :CAD} -> value({:BRL, :CAD}, variation)
      {:CAD, :BRL} -> value({:CAD, :BRL}, variation)
    end
  end

  defp value({:USD, :BRL}, 1), do: 0.22
  defp value({:BRL, :USD}, 1), do: 4.5
  defp value({:USD, :CAD}, 1), do: 0.8
  defp value({:CAD, :USD}, 1), do: 1.2
  defp value({:BRL, :CAD}, 1), do: 4.0
  defp value({:CAD, :BRL}, 1), do: 0.25

  defp value({:USD, :BRL}, 2), do: 0.2
  defp value({:BRL, :USD}, 2), do: 4.2
  defp value({:USD, :CAD}, 2), do: 1.0
  defp value({:CAD, :USD}, 2), do: 1.2
  defp value({:BRL, :CAD}, 2), do: 4.0
  defp value({:CAD, :BRL}, 2), do: 0.30

  defp value({:USD, :BRL}, 3), do: 0.1
  defp value({:BRL, :USD}, 3), do: 4.7
  defp value({:USD, :CAD}, 3), do: 1.6
  defp value({:CAD, :USD}, 3), do: 1.3
  defp value({:BRL, :CAD}, 3), do: 4.1
  defp value({:CAD, :BRL}, 3), do: 0.35
end
