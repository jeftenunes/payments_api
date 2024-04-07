defmodule PaymentsApiWeb.Channels.PaymentsServerSocket do
  use Phoenix.Socket
  use Absinthe.Phoenix.Socket, schema: PaymentsApiWeb.Schema

  def connect(_params, socket, _connection_info) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
