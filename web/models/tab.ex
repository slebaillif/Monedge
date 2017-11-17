defmodule Monedge.Tab do
  use Monedge.Web, :model

  schema "tabs" do
  field :name, :string
  field :currency, :string
  many_to_many :accounts, Monedge.Account, join_through: "tabs_accounts"
  many_to_many :transactions, Monedge.Transaction, join_through: "tabs_transactions"
  timestamps()
end

def changeset(struct, params  \\ %{}) do
  struct
  |> cast(params, [:name, :currency])
  |> cast_assoc(:accounts)
  |> cast_assoc(:transactions)
  |> validate_required([:name, :currency])
 end
end
