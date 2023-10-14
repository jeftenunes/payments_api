defmodule PaymentsApi.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :amount, :integer
      add :description, :string
      add :status, :string
      add :source, references(:wallets, on_delete: :nothing)

      timestamps()
    end

    create index(:transactions, [:source])
  end
end
