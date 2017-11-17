defmodule Monedge.Repo.Migrations.CreateTab do
  use Ecto.Migration

  def change do
    create table(:tabs) do
      add :name, :string
      add :currency, :string

      timestamps()
    end

    create unique_index(:tabs, [:name])

    create table(:tabs_transactions) do
      add :tab_id, references(:tabs)
      add :transaction_id, references(:transactions)
      timestamps()
    end

    create table(:tabs_accounts) do
      add :tab_id, references(:tabs)
      add :account_id, references(:accounts)
      timestamps()
    end
    
  end
end
