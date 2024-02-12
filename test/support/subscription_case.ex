defmodule PaymentsApiWeb.SubscriptionCase do
  require Phoenix.ChannelTest
  use ExUnit.CaseTemplate

  using do
    quote do
      use PaymentsApiWeb.Schema

      use Absinthe.Phoenix.SubscriptionTest,
        schema: PaymentsApiWeb.Schema

      setup do
        {:ok, socket} =
          Phoenix.ChannelTest.connect(PaymentsApiWeb.Channels.PaymentsServerSocket, %{})

        {:ok, socket} = Absinthe.Phoenix.SubscriptionTest.join_absinthe(socket)

        {:ok, %{socket: socket}}
      end
    end
  end
end
