defmodule ProductApi.Cache do
  @moduledoc """
  Cache module for managing currency rates and products caching.
  """

  require Logger

  @currency_cache :currency_cache
  @products_cache :products_cache
  
  # Cache TTL (Time To Live)
  @currency_ttl :timer.minutes(15)  # 15 minutes for currency rates
  @products_ttl :timer.minutes(5)   # 5 minutes for products

  ## Currency Cache Functions

  @doc """
  Get currency rate from cache or fetch if not exists.
  """
  def get_currency_rate(from_currency, to_currency) do
    key = "#{from_currency}_to_#{to_currency}"
    
    case Cachex.get(@currency_cache, key) do
      {:ok, nil} ->
        Logger.info("Currency rate cache miss for #{key}")
        {:error, :not_found}
      
      {:ok, rate} ->
        Logger.info("Currency rate cache hit for #{key}")
        {:ok, rate}
      
      {:error, _reason} ->
        Logger.warning("Currency cache error for #{key}")
        {:error, :cache_error}
    end
  end

  @doc """
  Set currency rate in cache with TTL.
  """
  def set_currency_rate(from_currency, to_currency, rate) do
    key = "#{from_currency}_to_#{to_currency}"
    
    case Cachex.put(@currency_cache, key, rate, ttl: @currency_ttl) do
      {:ok, true} ->
        Logger.info("Currency rate cached for #{key}: #{rate}")
        :ok
      
      {:error, reason} ->
        Logger.warning("Failed to cache currency rate for #{key}: #{inspect(reason)}")
        :error
    end
  end

  ## Products Cache Functions

  @doc """
  Get product from cache.
  """
  def get_product(product_id) do
    key = "product_#{product_id}"
    
    case Cachex.get(@products_cache, key) do
      {:ok, nil} ->
        Logger.debug("Product cache miss for ID #{product_id}")
        {:error, :not_found}
      
      {:ok, product} ->
        Logger.debug("Product cache hit for ID #{product_id}")
        {:ok, product}
      
      {:error, _reason} ->
        Logger.warning("Product cache error for ID #{product_id}")
        {:error, :cache_error}
    end
  end

  @doc """
  Set product in cache with TTL.
  """
  def set_product(product_id, product) do
    key = "product_#{product_id}"
    
    case Cachex.put(@products_cache, key, product, ttl: @products_ttl) do
      {:ok, true} ->
        Logger.debug("Product cached for ID #{product_id}")
        :ok
      
      {:error, reason} ->
        Logger.warning("Failed to cache product for ID #{product_id}: #{inspect(reason)}")
        :error
    end
  end

  @doc """
  Invalidate product cache when product is updated/deleted.
  """
  def invalidate_product(product_id) do
    key = "product_#{product_id}"
    
    case Cachex.del(@products_cache, key) do
      {:ok, true} ->
        Logger.debug("Product cache invalidated for ID #{product_id}")
        :ok
      
      {:error, reason} ->
        Logger.warning("Failed to invalidate product cache for ID #{product_id}: #{inspect(reason)}")
        :error
    end
  end

  @doc """
  Get cache statistics for monitoring.
  """
  def get_cache_stats do
    currency_stats = Cachex.stats(@currency_cache)
    products_stats = Cachex.stats(@products_cache)
    
    %{
      currency_cache: currency_stats,
      products_cache: products_stats
    }
  end

  @doc """
  Clear all caches (useful for development/testing).
  """
  def clear_all_caches do
    Cachex.clear(@currency_cache)
    Cachex.clear(@products_cache)
    Logger.info("All caches cleared")
    :ok
  end
end