defmodule PaymentsApi.PaymentsHelpers do
  def mock_exchange_rate_by_currency({to_currency, from_currency} = _currencies) do
    case {to_currency, from_currency} do
      {:USD, :BRL} -> "0.22"
      {:BRL, :USD} -> "4.5"
      {:USD, :CAD} -> "0.8"
      {:CAD, :USD} -> "1.20"
      {:BRL, :CAD} -> "4.0"
      {:CAD, :BRL} -> "0.25"
    end
  end
end
