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

  def find_by(%{id: id} = _params, _) do
    found = Accounts.get_user(String.to_integer(id))
    {:ok, found}
  end
end
