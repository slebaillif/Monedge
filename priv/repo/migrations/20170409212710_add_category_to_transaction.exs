defmodule Monedge.Repo.Migrations.AddCategoryToTransaction do
  use Ecto.Migration

  def change do
    alter table (:transactions) do
      add  :category_id, references(:categories, on_delete: :nothing)
    end
  end
end
