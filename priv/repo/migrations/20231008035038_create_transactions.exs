defmodule PaymentsApi.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :type, :string
      add :status, :string
      add :amount, :integer
      add :description, :string
      add :exchange_rate, :integer
      add :source_wallet_id, :integer
      add :recipient_wallet_id, references(:wallets, on_delete: :nothing)

      timestamps()
    end

    create index(:transactions, [:recipient_wallet_id])
  end
end
