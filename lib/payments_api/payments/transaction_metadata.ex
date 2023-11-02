defmodule PaymentsApi.Payments.TransactionMetadata do
  import Ecto.Query, warn: false

  alias PaymentsApi.Payments.Wallet

  def build_fetch_wallets_qry(source_id, recipient_id) do
    from(credit_wallet in Wallet,
      join: debt_wallet in Wallet,
      on: credit_wallet.id == ^recipient_id and debt_wallet.id == ^source_id,
      select: %{source: debt_wallet, recipient: credit_wallet}
    )
  end
end
