defmodule PaymentsApiWeb.Resolvers.UsersResolver do
  use Absinthe.Schema.Notation

  alias PaymentsApi.Accounts

  def find_user_by(%{email: _email} = params, _) do
    Accounts.get_user_by(params)
  end

  def create_user(%{email: _email} = params, _) do
    Accounts.create_user(params)
  end

  def all_users(_, _) do
    Accounts.all_users()
  end
end
