defmodule PaymentsApiWeb.Resolvers.UsersResolver do
  use Absinthe.Schema.Notation

  alias PaymentsApi.Payments
  alias PaymentsApiWeb.Resolvers.ErrorsHelper

  def create_user(%{email: _email} = params, _) do
    case Payments.create_user(params) do
      {:ok, usr} ->
        {:ok, usr}

      {:error, errors} when is_list(errors) ->
        {:error, errors}

      {:error, changeset} ->
        {:error, ErrorsHelper.traverse_errors(changeset)}
    end
  end

  def all_users(_, _) do
    {:ok, Payments.list_users(%{})}
  end

  def find_user_by(params, _) do
    {:ok, Payments.get_user(String.to_integer(params.id))}
  end
end
