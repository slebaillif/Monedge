defmodule Monedge.Repo.Migrations.AddUserToAccount do
  use Ecto.Migration

  def change do
    alter table (:accounts) do
      add  :user_id, references(:users, on_delete: :nothing)
    end
  end
end
