ExUnit.start()

Mox.defmock(ExchangeRateStoreMock,
  for: PaymentsApi.Currencies.ExchangeRateStoreBehaviour
)

Application.put_env(
  :payments_api,
  :exchange_rate_store,
  ExchangeRateStoreMock
)
