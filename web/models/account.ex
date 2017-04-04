defmodule Monedge.Account do
  use Monedge.Web, :model

  schema "accounts" do
  field :bank, :string
  field :currency, :string
  field :accountNumber,:string
  field :sortCode, :string
  field :label, :string
  field :accountCategory, :string
  timestamps()
end

def changeset(model, params \\:empty) do
  model
  |> cast(params , ~w[bank sortCode label accountNumber currency accountCategory], [])
end
end
