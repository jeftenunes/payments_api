defmodule PaymentsApiWeb.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use PaymentsApiWeb.DataCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  alias PaymentsApi.{PaymentsFixtures, PaymentsHelpers}

  using do
    quote do
      import Ecto
      import Ecto.Query
      import Ecto.Changeset
      import PaymentsApiWeb.DataCase

      alias PaymentsApi.Repo
    end
  end

  setup tags do
    PaymentsApiWeb.DataCase.setup_sandbox(tags)

    :ok
  end

  setup _context do
    user1 = PaymentsFixtures.user_fixture(%{email: "test@email.com"})

    PaymentsFixtures.wallet_fixture(%{user_id: to_string(user1.id), currency: "BRL"})
    PaymentsFixtures.wallet_fixture(%{user_id: to_string(user1.id), currency: "CAD"})

    PaymentsFixtures.user_fixture(%{email: "test1@email.com"})

    :ok
  end

  @doc """
  Sets up the sandbox based on the test tags.
  """
  def setup_sandbox(tags) do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(PaymentsApi.Repo)
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(PaymentsApi.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)

    Mox.stub(MockAlphaVantageApiClient, :fetch, fn %{
                                                     to_currency: to_currency,
                                                     from_currency: from_currency
                                                   } = _params ->
      %{
        bid_price: "1.50",
        ask_price: "2.10",
        to_currency: to_string(to_currency),
        exchange_rate:
          PaymentsHelpers.mock_exchange_rate_by_currency({to_currency, from_currency}),
        from_currency: to_string(from_currency),
        last_refreshed: DateTime.now!("Etc/UTC")
      }
    end)

    :ok
  end

  @doc """
  A helper that transforms changeset errors into a map of messages.

      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
