defmodule PaymentsApiWeb.Resolvers.UsersResolver do
  use Absinthe.Schema.Notation

  alias PaymentsApiWeb.Resolvers.ErrorsHelper
  alias PaymentsApi.{Payments, UserTotalWorth}

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
    {:ok, Payments.all_users()}
  end

  def find_user_by(params, _) do
    {:ok, Payments.get_users_by_email(params.email)}
  end

  def find_user_total_worth_by(params, _) do
    case UserTotalWorth.retrieve_total_worth_for_user(%{
           id: params.user_id,
           currency: params.currency
         }) do
      %{
        currency: _currency,
        exchange_rate: _exchange_rate,
        user_id: _user_id,
        total_worth: _total_worth
      } = total_worth ->
        {:ok, total_worth}

      errors when is_list(errors) ->
        ErrorsHelper.build_graphql_error(errors)
    end
  end
end
