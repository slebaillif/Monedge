defmodule Monedge.Repo.Migrations.AddSugstionToTransactions do
  use Ecto.Migration

  def change do
    alter table (:transactions) do
      add  :suggestion_id, references(:categories, on_delete: :nothing)
    end
  end
end
