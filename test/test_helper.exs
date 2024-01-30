ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(PaymentsApi.Repo, :manual)

Mox.defmock(MockAlphaVantageApiWrapper,
  for: PaymentsApi.Payments.Currencies.AlphaVantageApiWrapper
)

Application.put_env(
  :payments_api,
  :alpha_vantage_api_wrapper,
  MockAlphaVantageApiWrapper
)
