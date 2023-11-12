defmodule PaymentsApi.Payments.PaymentProcessingServer do
  use GenServer

  alias PaymentsApi.Payments

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
    transactions = Payments.retrieve_transactions_to_process()

    {:noreply, state}
  end
end
