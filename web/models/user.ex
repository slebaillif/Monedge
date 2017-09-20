defmodule Monedge.User do
    use Monedge.Web, :model
  
    schema "users" do
    field :firstName, :string
    field :lastName, :string
    timestamps()
  end
  
  def changeset(model, params \\:empty) do
    model
    |> cast(params , ~w[firstName lastName], [])
  end
  end