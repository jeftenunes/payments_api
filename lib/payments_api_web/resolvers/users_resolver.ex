defmodule PaymentsApiWeb.Resolvers.UsersResolver do
  alias PaymentsApi.Accounts

  use Absinthe.Schema.Notation

  def create_user(%{email: email} = _params, _) do
    Accounts.create_user(%{email: email})
  end

  def find_by(%{id: id} = _params, _) do
    found = Accounts.get_user(String.to_integer(id))
    {:ok, found}
  end
end
