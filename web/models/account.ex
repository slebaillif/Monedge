defmodule Monedge.Account do
  use Monedge.Web, :model

  schema "accounts" do
  field :bank, :string
  field :currency, :string
  field :accountNumber,:string
  field :sortCode, :string
  field :label, :string
  field :accountCategory, :string
  belongs_to :user, Monedge.User
  belongs_to :joint_user, Monedge.User
  timestamps()
end

def changeset(struct, params  \\ %{}) do
  struct
  |> cast(params, [:bank, :sortCode, :label ,:accountNumber ,:currency ,:accountCategory, :user_id, :joint_user_id])
  |> cast_assoc(:user)
  |> cast_assoc(:joint_user)
  |> validate_required([:bank, :sortCode, :accountNumber, :currency, :user_id])
 end
end
