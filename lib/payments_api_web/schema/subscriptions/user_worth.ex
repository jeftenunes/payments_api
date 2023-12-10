defmodule PaymentsApiWeb.Schema.Subscriptions.UserWorth do
  use Absinthe.Schema.Notation

  object :user_worth_subscriptions do
    field :user_total_worth_updated, list_of(:total_worth) do
      arg(:user_id, :id)

      config(fn args, _ -> {:ok, topic: "user_total_worth_updated:#{args.user_id}"} end)
    end
  end
end
