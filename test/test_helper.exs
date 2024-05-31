ExUnit.start()

Application.put_env(
  :payments_api,
  :exchange_rate_store,
  PaymentsApi.Currencies.ExchangeRateStoreMock
)
