defmodule Monedge.Repo.Migrations.AddJointUserToAccount do
  use Ecto.Migration

  def change do
    alter table (:accounts) do
      add  :joint_user_id, references(:users, on_delete: :nothing)
    end
  end
end
