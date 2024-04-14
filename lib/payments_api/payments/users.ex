defmodule PaymentsApi.Payments.Users do
  alias PaymentsApi.Repo
  alias PaymentsApi.Payments.Users.User

  def get_user_by(%{id: id}) do
    id
    |> User.find_users()
    |> Repo.all()
    |> build_users_list()
    |> List.first()
  end

  def get_user_by(%{email: email}) do
    email
    |> User.find_user_by_email()
    |> Repo.all()
    |> build_users_list()
    |> List.first()
  end

  def user_exists(id),
    do: id |> User.build_exists_qry() |> Repo.exists?()

  def list_users(params) do
    params |> User.find_users() |> Repo.all() |> build_users_list()
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  defp build_users_list(data) do
    wallets =
      data
      |> Enum.map(fn item -> item.wallet end)
      |> Enum.filter(fn w -> w !== nil end)

    users =
      data
      |> Enum.map(fn item -> item.user end)
      |> Enum.uniq()

    Enum.map(users, fn user ->
      Map.put(
        user,
        :wallets,
        Enum.filter(wallets, fn wallet -> wallet.user_id === user.id end)
      )
    end)
  end
end
