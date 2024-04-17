defmodule PaymentsApiWeb.PaymentsServerSocket do
  use Phoenix.Socket

  channel "__absinthe__:*", PaymentsApiWeb.TrackSubscriptionsChannel,
    assigns: %{
      __absinthe_schema__: PaymentsApiWeb.Schema,
      __absinthe_pipeline__: nil
    }

  def connect(params, socket) do
    IO.inspect(params)
    {:ok, socket}
  end

  def id(_socket), do: nil

  defdelegate put_options(socket, opts), to: Absinthe.Phoenix.Socket
  defdelegate put_schema(socket, schema), to: Absinthe.Phoenix.Socket
end
