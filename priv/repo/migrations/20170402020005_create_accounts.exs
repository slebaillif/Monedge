defmodule Monedge.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :bank, :string
      add :currency, :string
      add :accountNumber,:string
      add :sortCode, :string
      add :label, :string
      add :accountCategory, :string
      timestamps()
    end

    create unique_index(:accounts, [:sortCode,:accountNumber])
  end
end
