ExUnit.start()

Mox.defmock(ExchangeRateStoreMock,
  for: PaymentsApi.Currencies.ExchangeRateStoreBehaviour
)

Mox.defmock(AlphaVantageApiClientMock,
  for: PaymentsApi.Currencies.AlphaVantageApiClient
)

Application.put_env(
  :payments_api,
  :alpha_vantage_api_client,
  AlphaVantageApiClientMock
)

Application.put_env(
  :payments_api,
  :exchange_rate_store,
  ExchangeRateStoreMock
)
