defmodule Monedge.Repo.Migrations.CreateTransaction do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :date, :date
      add :description, :text
      add :amount, :float
      add :currency, :string
      add :account_id, references(:account, on_delete: :nothing)

      timestamps()
    end
    create index(:transactions, [:account_id])

  end
end
