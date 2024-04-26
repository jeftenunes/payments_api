defmodule PaymentsApiWeb.PaymentsServerSocket do
  use Phoenix.Socket
  use Absinthe.Phoenix.Socket, schema: PaymentsApiWeb.Schema

  @impl true
  def connect(_params, socket) do
    {:ok, socket}
  end

  @impl true
  def id(_socket), do: nil
end
