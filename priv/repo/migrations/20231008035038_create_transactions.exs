defmodule PaymentsApi.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :status, :string
      add :amount, :integer
      add :description, :string
      add :exchange_rate, :integer
      add :source, references(:wallets, on_delete: :nothing)
      add :recipient, references(:wallets, on_delete: :nothing)

      timestamps()
    end

    create index(:transactions, [:source])
    create index(:transactions, [:recipient])
  end
end
