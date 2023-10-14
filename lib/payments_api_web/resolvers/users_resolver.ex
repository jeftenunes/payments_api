defmodule PaymentsApiWeb.Resolvers.UsersResolver do
  use Absinthe.Schema.Notation

  alias PaymentsApi.Accounts
  alias PaymentsApiWeb.Resolvers.ErrorsHelper

  def create_user(%{email: _email} = params, _) do
    case Accounts.create_user(params) do
      {:ok, usr} ->
        {:ok, usr}

      {:error, changeset} ->
        {:error, ErrorsHelper.traverse_errors(changeset)}
    end
  end

  def all_users(_, _) do
    {:ok, Accounts.list_users(%{})}
  end

  def find_user_by(params, _) do
    {:ok, Accounts.get_user(String.to_integer(params.id))}
  end
end
