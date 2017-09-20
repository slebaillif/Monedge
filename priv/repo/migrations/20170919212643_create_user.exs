defmodule Monedge.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :firstName, :string
      add :lastName, :string
      timestamps()
    end

    create unique_index(:users, [:firstName,:lastName])
  end
end
