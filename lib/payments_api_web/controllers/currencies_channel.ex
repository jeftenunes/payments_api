defmodule PaymentsApiWeb.CurrenciesChannel do
  use PaymentsApiWeb, :channel

  def join("exchange_rate_updated", _payload, socket) do
    {:ok, socket}
  end

  def handle_in(_, socket) do
    broadcast(socket, "exchange_rate_updated", nil)
    {:reply, socket, %{"accepted" => true}}
  end
end
