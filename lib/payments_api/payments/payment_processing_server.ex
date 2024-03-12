defmodule PaymentsApi.Payments.PaymentProcessingServer do
  use GenServer

  alias PaymentsApi.Payments
  alias PaymentsApi.Payments.Currencies

  @default_name PaymentProcessingServer

  defstruct supervisor: nil

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, %{}, name: @default_name)
  end

  ## server callbacks
  @impl true
  def init(state) do
    {:ok, supervisor} = Task.Supervisor.start_link()

    state = Map.put(state, :supervisor, supervisor)

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
  def handle_info(:process_pending_transactions, %{supervisor: supervisor} = state) do
    Task.Supervisor.start_child(supervisor, fn ->
      Payments.process_transaction()
      |> Enum.filter(fn {_k, v} -> v.status === "PROCESSED" end)
      |> Enum.each(fn {_k, processed} ->
        usr = Payments.find_user_by_wallet_id_qry(processed.wallet_id)

        publish_user_total_worth_updates(supervisor, usr.id)
      end)
    end)

    {:noreply, state}
  end

  defp publish_user_total_worth_updates(supervisor, user_id) do
    user_total_worth =
      Enum.map(Currencies.get_supported_currencies(), fn {currency_key, _currency_infos} ->
        Payments.retrieve_total_worth_for_user(%{id: user_id, currency: to_string(currency_key)})
      end)

    Task.Supervisor.start_child(supervisor, fn ->
      Absinthe.Subscription.publish(
        PaymentsApiWeb.Endpoint,
        user_total_worth,
        user_total_worth_updated: "user_total_worth_updated:#{user_id}"
      )
    end)
  end
end
