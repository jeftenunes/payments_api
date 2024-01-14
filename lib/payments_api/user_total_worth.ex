defmodule PaymentsApi.UserTotalWorth do
  alias PaymentsApi.Payments
  alias PaymentsApi.UserTotalWorth.Store

  def track_user_total_worth(user_id) do
    case Store.get_user_worth_summary(user_id) do
      nil ->
        total_worth =
          Payments.retrieve_total_worth_for_user(%{id: user_id, currency: nil})

        Store.save_user_worth_summary(total_worth)
        {:ok, total_worth}

      total_worth ->
        {:ok, total_worth}
    end
  end

  def untrack_user_total_worth(user_id) do
    Store.remove_user_worth_summary(user_id)
  end
end
