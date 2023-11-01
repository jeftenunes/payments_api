defmodule PaymentsApiWeb.Resolvers.PaymentsResolver do
  use Absinthe.Schema.Notation

  alias PaymentsApi.Payments
  alias PaymentsApiWeb.Resolvers.ErrorsHelper

  def send_money(%{} = params, _) do
    case Payments.create_transaction(params) do
      {:ok, transaction} ->
        {:ok, transaction}

      {:error, errors} when is_list(errors) ->
        {:error, errors}

      {:error, changeset} ->
        {:error, ErrorsHelper.traverse_errors(changeset)}
    end
  end
end
