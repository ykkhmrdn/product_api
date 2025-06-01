defmodule ProductApiWeb.ProductController do
  use ProductApiWeb, :controller

  alias ProductApi.Products
  alias ProductApi.Products.Product

  action_fallback ProductApiWeb.FallbackController

  def index(conn, params) do
    page = String.to_integer(params["page"] || "1")
    result = Products.list_products(page: page)
    
    conn
    |> put_view(json: ProductApiWeb.ProductJSON)
    |> render(:index, products: result.products, pagination: result.pagination)
  end

  def create(conn, product_params) do
    with {:ok, %Product{} = product} <- Products.create_product(product_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/products/#{product}")
      |> render(:show, product: product)
    end
  end

  def show(conn, %{"id" => id}) do
    product = Products.get_product!(id)
    render(conn, :show, product: product)
  end

  def update(conn, %{"id" => id} = params) do
    product = Products.get_product!(id)
    product_params = Map.drop(params, ["id"])

    with {:ok, %Product{} = product} <- Products.update_product(product, product_params) do
      render(conn, :show, product: product)
    end
  end

  def delete(conn, %{"id" => id}) do
    product = Products.get_product!(id)

    with {:ok, %Product{}} <- Products.delete_product(product) do
      send_resp(conn, :no_content, "")
    end
  end
end