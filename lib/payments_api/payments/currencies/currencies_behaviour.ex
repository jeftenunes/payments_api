defmodule PaymentsApi.Payments.Currencies.CurrenciesBehaviour do
  @moduledoc false

  # corrigir o behaviour
  @callback fetch(map :: map()) :: map()
  @callback fetch(map :: map()) :: tuple()
end
