defmodule PaymentsApiWeb.Resolvers.PaymentsResolver do
  use Absinthe.Schema.Notation

  alias PaymentsApi.Payments
  alias PaymentsApiWeb.Resolvers.ErrorsHelper

  def send_money(%{} = params, _) do
    case Payments.create_transaction(params) do
      {:ok, transaction} ->
        {:ok, transaction}

      errors when is_list(errors) ->
        ErrorsHelper.build_graphql_error(errors)
    end
  end
end
