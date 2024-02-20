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

  def mock_exchange_rate_by_currency_with_variation({to_currency, from_currency} = _currencies) do
    case {to_currency, from_currency} do
      {:USD, :BRL} -> "#{0.22 + 0.22 * :rand.uniform(20 - 10) / 100}"
      {:BRL, :USD} -> "#{4.5 + 4.5 * :rand.uniform(20 - 10) / 100}"
      {:USD, :CAD} -> "#{0.8 + 0.8 * :rand.uniform(20 - 10) / 100}"
      {:CAD, :USD} -> "#{1.20 + 1.20 * :rand.uniform(20 - 10) / 100}"
      {:BRL, :CAD} -> "#{4.0 + 4.0 * :rand.uniform(20 - 10) / 100}"
      {:CAD, :BRL} -> "#{0.25 + 0.25 * :rand.uniform(20 - 10) / 100}"
    end
  end
end
