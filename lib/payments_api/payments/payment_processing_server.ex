defmodule PaymentsApi.Payments.PaymentProcessingServer do
  use GenServer

  @default_name PaymentProcessingServer

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, %{}, name: @default_name)
  end

  ## server callbacks
  @impl true
  def init(state) do
    {:ok, state, {:continue, :start}}
  end
end
