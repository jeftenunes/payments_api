defmodule PaymentsApiWeb.Channels.PaymentsServerSocket do
  use Phoenix.Socket
  use Absinthe.Phoenix.Socket, schema: PaymentsApiWeb.Schema

  channel "exchange_rate_updated", schema: PaymentsApiWeb.CurrenciesChannel
  channel "user_total_worth_updated", schema: PaymentsApiWeb.TotalWorthChannel

  def connect(_params, socket, _connection_info) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
