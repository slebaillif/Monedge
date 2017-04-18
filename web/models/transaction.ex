defmodule Monedge.Transaction do
  use Monedge.Web, :model

  schema "transactions" do
    field :date, Ecto.Date
    field :description, :string
    field :amount, :float
    field :currency, :string
    belongs_to :account, Monedge.Account
    belongs_to :category, Monedge.Category
    belongs_to :suggestion, Monedge.Category

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:date, :description, :amount, :currency, :account_id, :category_id, :suggestion_id])
    |> cast_assoc(:account)
    |> cast_assoc(:category)
    |> cast_assoc(:suggestion)
    |> validate_required([:date, :description, :amount, :currency])
  end
end
