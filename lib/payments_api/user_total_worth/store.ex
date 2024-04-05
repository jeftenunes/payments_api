defmodule PaymentsApi.UserTotalWorth.Store do
  @moduledoc """
    Agent to hold user total worth
  """

  use Agent

  @default_name UserTotalWorthStore

  def start_link(opts \\ []) do
    opts = Keyword.put_new(opts, :name, @default_name)

    {:ok, supervisor} = Task.Supervisor.start_link()
    state = Map.put(%{}, :supervisor, supervisor)

    Agent.start_link(fn -> state end, opts)
  end

  def get_user_by_worth_summary(agent \\ @default_name, user_id) do
    Agent.get(agent, &Map.get(&1, user_id, %{}))
  end

  def remove_user_worth_summary(agent \\ @default_name, user_id) do
    Agent.update(agent, fn state -> Map.pop(state, user_id) end)
  end

  def save_user_worth_summary(agent \\ @default_name, user_worth_summary) do
    Agent.update(agent, fn state ->
      case Map.get(state, user_worth_summary.user_id) do
        nil ->
          Map.put(state, user_worth_summary.user_id, user_worth_summary)

        user_worth_summary ->
          publish_user_total_worth_update(user_worth_summary)
          Map.put(state, user_worth_summary.user_id, user_worth_summary)
      end
    end)
  end

  def publish_user_total_worth_update(user_worth_summary) do
    Absinthe.Subscription.publish(
      PaymentsApiWeb.Endpoint,
      user_worth_summary,
      user_total_worth_updated: "user_total_worth_updated:#{user_worth_summary.user_id}"
    )
  end
end
