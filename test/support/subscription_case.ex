defmodule PaymentsApiWeb.SubscriptionCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use PaymentsApiWeb.ChannelCase

      use Absinthe.Phoenix.SubscriptionTest,
        schema: PaymentsApiWeb.Schema

      setup do
        {:ok, socket} =
          Phoenix.ChannelTest.connect(PaymentsApiWeb.PaymentsServerSocket, %{})

        {:ok, socket} = Absinthe.Phoenix.SubscriptionTest.join_absinthe(socket)

        {:ok, %{socket: socket}}
      end
    end
  end
end
