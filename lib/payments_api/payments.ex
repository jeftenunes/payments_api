defmodule PaymentsApi.Payments do
  alias EctoShorts.Actions
  alias PaymentsApi.Payments.Transaction

  def create_transaction(%{} = params) do
    Actions.create(Transaction, params)
  end
end
