defmodule PaymentsApiWeb.TrackSubscriptionsChannel do
  use Phoenix.Channel

  def join(topic, payload, socket) do
    # your join logic where you can tack join event
    Absinthe.Phoenix.Channel.join(topic, payload, socket)
  end

  def handle_in("unsubscribe", payload, socket) do
    {:reply, :ok, socket}
  end

  def handle_in(evt, payload, socket) do
    IO.inspect(evt)
    IO.inspect(payload)

    Absinthe.Phoenix.Channel.handle_in(evt, payload, socket)
  end

  def terminate(_reason, socket) do
    {:ok, socket}
  end

  defdelegate default_pipeline(schema, options), to: Absinthe.Phoenix.Channel
end
