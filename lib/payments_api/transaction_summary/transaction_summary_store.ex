defmodule PaymentsApi.TransactionSummary.TransactionSummaryStore do
  use Agent

  @default_name TransactionAgent

  defstruct supervisor: nil

  def start_link(opts \\ []) do
    opts = Keyword.put_new(opts, :name, @default_name)
    Agent.start_link(fn -> %{} end, opts)
  end

  def get_user_worth_summary(agent \\ @default_name, user_id, _currency) do
    Agent.get(agent, &Map.get(&1, user_id, %{}))
  end

  def save_user_worth_summary(agent \\ @default_name, user_worth_summary) do
    Agent.update(agent, fn state ->
      case Map.get(state, user_worth_summary.user_id) do
        nil ->
          Map.put(state, user_worth_summary.user_id, user_worth_summary)

        user_worth_summary ->
          Map.put(state, user_worth_summary.user_id, user_worth_summary.user_id)
      end
    end)
  end
end
