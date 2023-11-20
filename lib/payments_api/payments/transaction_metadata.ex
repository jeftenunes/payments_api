defmodule PaymentsApi.Payments.TransactionMetadata do
  import Ecto.Query, warn: false

  alias PaymentsApi.Payments.Wallet

  def build_fetch_wallets_qry(source_id, recipient_id) do
    from(credit_wallet in Wallet,
      join: debit_wallet in Wallet,
      on: credit_wallet.id == ^recipient_id and debit_wallet.id == ^source_id,
      select: %{source: debit_wallet, recipient: credit_wallet}
    )
  end
end
