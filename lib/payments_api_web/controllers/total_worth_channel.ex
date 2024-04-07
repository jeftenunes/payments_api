defmodule PaymentsApiWeb.TotalWorthChannel do
  use PaymentsApiWeb, :channel

  def join("user_total_worth_updated:4", _payload, socket) do
    IO.inspect("xxxx")
    {:ok, socket}
  end

  def handle_in(_, socket) do
    broadcast(socket, "user_total_worth_updated", nil)
    {:reply, socket, %{"accepted" => true}}
  end
end
