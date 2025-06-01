defmodule ProductApi.Products.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :name, :string
    field :price_idr, :decimal

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :price_idr])
    |> validate_required([:name, :price_idr], message: "can't be blank")
    |> validate_length(:name, min: 1, message: "can't be blank")
    |> validate_number(:price_idr, greater_than: 0, message: "must be greater than 0")
    |> unique_constraint(:name, message: "has already been taken")
  end
end