ExUnit.start()

Mox.defmock(MockAlphaVantageApiClient,
  for: PaymentsApi.Currencies.AlphaVantageApiClient
)

Application.put_env(
  :payments_api,
  :alpha_vantage_api_client,
  MockAlphaVantageApiClient
)
