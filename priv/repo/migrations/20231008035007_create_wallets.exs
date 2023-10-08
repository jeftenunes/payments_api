defmodule PaymentsApi.Repo.Migrations.CreateWallets do
  use Ecto.Migration

  def change do
    create table(:wallets) do
      add :balance, :integer
      add :currency, :string
      add :userid, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:wallets, [:userid])
  end
end
