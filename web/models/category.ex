defmodule Monedge.Category do
  use Monedge.Web, :model

  schema "categories" do
    field :name, :string
    field :description, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :description])
    |> validate_required([:name, :description])
  end

  def accountTypes() do
    [:current, :savings, :credit, :mortgage]
  end
end
