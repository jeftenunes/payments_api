defmodule PaymentsApiWeb.ChannelCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Phoenix.ChannelTest
      @endpoint PaymentsApiWeb.Endpoint
    end
  end
end
