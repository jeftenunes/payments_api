defmodule PaymentsApiWeb.Resolvers.PaymentsResolver do
  use Absinthe.Schema.Notation

  alias PaymentsApi.Payments

  def send_money(%{} = params, _) do
    case Payments.send_money(params) do
      {:ok, transaction} ->
        {:ok, transaction}

      errors ->
        errors
    end
  end
end
