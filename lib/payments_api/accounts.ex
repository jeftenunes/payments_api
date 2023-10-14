defmodule PaymentsApi.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias PaymentsApi.Repo
  alias PaymentsApi.Accounts.{User, Wallet}
  alias PaymentsApiWeb.Resolvers.ErrorsHelper
  alias PaymentsApi.Payments.Currencies.Currency

  def get_user(id) do
    User.find_users(id)
    |> Repo.all()
    |> build_users_list()
    |> List.first()
  end

  def user_exists(id),
    do: User.build_exists_qry(id) |> Repo.exists?()

  def list_users(params) do
    User.find_users(params) |> Repo.all() |> build_users_list()
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def list_wallets(params) do
    Wallet.build_find_wallets_by_qry(params) |> Repo.all()
  end

  def get_wallet(id), do: Repo.get!(Wallet, id)

  def create_wallet(%{user_id: user_id, currency: currency} = attrs) do
    case {user_exists(String.to_integer(user_id)), Currency.is_supported?(currency)} do
      {true, true} ->
        build_wallet_initial_state(attrs)
        |> Wallet.changeset(attrs)
        |> Repo.insert()

      {false, _} ->
        ErrorsHelper.build_graphql_error(["User does not exist"])

      {_, false} ->
        ErrorsHelper.build_graphql_error(["Currency not supported"])
    end
  end

  ## helpers

  defp build_wallet_initial_state(attrs) do
    %Wallet{balance: 0, currency: attrs.currency, user_id: String.to_integer(attrs.user_id)}
  end

  defp build_users_list(data) do
    wallets =
      data
      |> Enum.map(fn item -> item.wallet end)
      |> Enum.filter(fn w -> w != nil end)

    users =
      data
      |> Enum.map(fn item -> item.user end)
      |> Enum.uniq()

    IO.inspect(wallets)

    Enum.map(users, fn user ->
      Map.put(
        user,
        :wallets,
        Enum.filter(wallets, fn wallet -> wallet.user_id == user.id end)
      )
    end)
  end
end
