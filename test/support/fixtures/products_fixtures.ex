defmodule ProductApi.ProductsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ProductApi.Products` context.
  """

  @doc """
  Generate a unique product name.
  """
  def unique_product_name, do: "some name#{System.unique_integer([:positive])}"

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        name: unique_product_name(),
        price_idr: "120.5"
      })
      |> ProductApi.Products.create_product()

    product
  end
end
