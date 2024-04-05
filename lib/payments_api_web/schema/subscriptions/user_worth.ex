defmodule PaymentsApiWeb.Schema.Subscriptions.UserWorth do
  use Absinthe.Schema.Notation

  alias PaymentsApi.UserTotalWorth

  object :user_worth_subscriptions do
    field :user_total_worth_updated, list_of(:total_worth) do
      arg :id, :id

      trigger :create_user,
        topic: fn args ->
          "user_total_worth_updated:#{args.id}"
        end

      config fn args, _ ->
        UserTotalWorth.track_user_total_worth(args.id)
        {:ok, topic: "user_total_worth_updated:#{args.id}"}
      end
    end
  end
end
