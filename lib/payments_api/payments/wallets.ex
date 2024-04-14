defmodule PaymentsApi.Payments.Wallets do
  alias PaymentsApi.Repo
  alias PaymentsApi.Payments.{Currencies, Users, Wallets.Wallet}

  def list_wallets(params) do
    params
    |> Wallet.build_find_wallets_by_qry()
    |> Repo.all()
  end

  def get_wallet(id), do: Repo.get!(Wallet, id)

  def create_wallet(%{user_id: user_id, currency: currency} = attrs) do
    case {Users.user_exists(String.to_integer(user_id)), Currencies.supported?(currency)} do
      {true, true} ->
        {:ok, wallet} =
          attrs
          |> build_wallet_initial_state()
          |> Wallet.changeset(attrs)
          |> Repo.insert()

        wallet

      {false, _} ->
        ["User does not exist"]

      {_, false} ->
        ["Currencies not supported"]
    end
  end

  def find_user_by_wallet_id_qry(wallet_id) do
    wallet_id
    |> Wallet.build_find_user_by_wallet_id_qry()
    |> Repo.one!()
  end

  def retrieve_transaction_wallets(source_id, recipient_id) do
    Repo.one(Wallet.build_fetch_wallets_qry(source_id, recipient_id))
  end

  defp build_wallet_initial_state(attrs) do
    %Wallet{currency: attrs.currency, user_id: String.to_integer(attrs.user_id)}
  end
end
