ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(PaymentsApi.Repo, :manual)

Mox.defmock(CurrenciesBehaviourMock,
  for: PaymentsApi.Payments.Currencies.CurrenciesBehaviour
)

Application.put_env(
  :payments_api,
  :currencies,
  CurrenciesBehaviourMock
)
