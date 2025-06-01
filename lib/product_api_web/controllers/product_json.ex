defmodule ProductApiWeb.ProductJSON do
  alias ProductApi.Products.Product

  @doc """
  Renders a list of products with pagination.
  """
  def index(%{products: products, pagination: pagination}) do
    %{
      data: for(product <- products, do: data(product)),
      pagination: pagination
    }
  end

  @doc """
  Renders a single product.
  """
  def show(%{product: product}) do
    %{data: data(product)}
  end

  defp data(%Product{} = product) do
    %{
      id: product.id,
      name: product.name,
      price_idr: product.price_idr |> Decimal.to_float() |> :erlang.float_to_binary([decimals: 2]),
      inserted_at: product.inserted_at,
      updated_at: product.updated_at
    }
  end
end