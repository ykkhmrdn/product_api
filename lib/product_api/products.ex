defmodule ProductApi.Products do
  @moduledoc """
  The Products context with caching support.
  """

  import Ecto.Query, warn: false
  alias ProductApi.Repo
  alias ProductApi.Cache
  alias ProductApi.Products.Product

  require Logger

  @doc """
  Returns the list of products with pagination.

  ## Examples

      iex> list_products()
      [%Product{}, ...]

      iex> list_products(page: 2)
      [%Product{}, ...]

  """
  def list_products(opts \\ []) do
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 10)
    
    offset = (page - 1) * per_page
    
    products = 
      Product
      |> order_by(desc: :inserted_at)
      |> limit(^per_page)
      |> offset(^offset)
      |> Repo.all()
    
    total_count = Repo.aggregate(Product, :count, :id)
    total_pages = ceil(total_count / per_page)
    
    %{
      products: products,
      pagination: %{
        page: page,
        per_page: per_page,
        total: total_count,
        total_pages: total_pages
      }
    }
  end

  @doc """
  Gets a single product with caching support.

  Raises `Ecto.NoResultsError` if the Product does not exist.

  ## Examples

      iex> get_product!(123)
      %Product{}

      iex> get_product!(456)
      ** (Ecto.NoResultsError)

  """
  def get_product!(id) do
    case Cache.get_product(id) do
      {:ok, product} ->
        Logger.debug("Product #{id} retrieved from cache")
        product
      
      {:error, :not_found} ->
        Logger.debug("Product #{id} not in cache, fetching from database")
        product = Repo.get!(Product, id)
        
        # Cache the product for future requests
        Cache.set_product(id, product)
        product
      
      {:error, _reason} ->
        Logger.warning("Cache error for product #{id}, falling back to database")
        Repo.get!(Product, id)
    end
  end

  @doc """
  Creates a product.

  ## Examples

      iex> create_product(%{field: value})
      {:ok, %Product{}}

      iex> create_product(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_product(attrs \\ %{}) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a product and invalidates cache.

  ## Examples

      iex> update_product(product, %{field: new_value})
      {:ok, %Product{}}

      iex> update_product(product, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_product(%Product{} = product, attrs) do
    result = 
      product
      |> Product.changeset(attrs)
      |> Repo.update()
    
    case result do
      {:ok, updated_product} ->
        # Invalidate cache since product was updated
        Cache.invalidate_product(product.id)
        Logger.debug("Product #{product.id} cache invalidated after update")
        {:ok, updated_product}
      
      error ->
        error
    end
  end

  @doc """
  Deletes a product and invalidates cache.

  ## Examples

      iex> delete_product(product)
      {:ok, %Product{}}

      iex> delete_product(product)
      {:error, %Ecto.Changeset{}}

  """
  def delete_product(%Product{} = product) do
    result = Repo.delete(product)
    
    case result do
      {:ok, deleted_product} ->
        # Invalidate cache since product was deleted
        Cache.invalidate_product(product.id)
        Logger.debug("Product #{product.id} cache invalidated after deletion")
        {:ok, deleted_product}
      
      error ->
        error
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking product changes.

  ## Examples

      iex> change_product(product)
      %Ecto.Changeset{data: %Product{}}

  """
  def change_product(%Product{} = product, attrs \\ %{}) do
    Product.changeset(product, attrs)
  end
end