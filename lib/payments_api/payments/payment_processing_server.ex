defmodule PaymentsApi.Payments.PaymentProcessingServer do
  use GenServer

  alias PaymentsApi.UserTotalWorth
  alias PaymentsApi.Payments.{Currencies, Transactions, Wallets}

  @default_name PaymentProcessingServer

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, %{}, name: @default_name)
  end

  ## server callbacks
  @impl true
  def init(state) do
    {:ok, state, {:continue, :start}}
  end

  @impl true
  def handle_continue(:start, state) do
    :timer.send_interval(
      1000,
      :process_pending_transactions
    )

    {:noreply, state}
  end

  @impl true
  def handle_info(:process_pending_transactions, state) do
    # Transactions.process_transaction()
    # |> Enum.filter(fn {_k, v} -> v.status === "PROCESSED" end)
    # |> Enum.each(fn {_k, processed} ->
    #   usr = Wallets.find_user_by_wallet_id_qry(processed.wallet_id)

    #   publish_user_total_worth_updates(usr.id)
    # end)

    {:noreply, state}
  end

  defp publish_user_total_worth_updates(user_id) do
    user_total_worth =
      Enum.map(Currencies.get_supported_currencies(), fn {currency_key, _currency_infos} ->
        UserTotalWorth.retrieve_total_worth_for_user(%{
          id: user_id,
          currency: to_string(currency_key)
        })
      end)

    Absinthe.Subscription.publish(
      PaymentsApiWeb.Endpoint,
      user_total_worth,
      user_total_worth_updated: "user_total_worth_updated:#{user_id}"
    )
  end
end
