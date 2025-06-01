defmodule ProductApi.Currency do
  @moduledoc """
  Module for currency conversion operations with caching.
  """

  require Logger
  alias ProductApi.Cache

  @base_url "https://api.exchangerate-api.com/v4/latest/"

  @doc """
  Convert IDR to USD using cached exchange rates when possible.
  
  ## Examples
  
      iex> convert_idr_to_usd(50000)
      {:ok, 3.33}
      
      iex> convert_idr_to_usd(invalid)
      {:error, :conversion_failed}
  """
  def convert_idr_to_usd(idr_amount) when is_number(idr_amount) do
    case get_cached_exchange_rate() do
      {:ok, rate} ->
        usd_amount = idr_amount * rate
        {:ok, Float.round(usd_amount, 2)}
      
      {:error, reason} ->
        Logger.warning("Currency conversion failed: #{inspect(reason)}")
        {:error, :conversion_failed}
    end
  end

  def convert_idr_to_usd(_), do: {:error, :invalid_amount}

  defp get_cached_exchange_rate do
    case Cache.get_currency_rate("IDR", "USD") do
      {:ok, rate} ->
        Logger.info("Using cached exchange rate: #{rate}")
        {:ok, rate}
      
      {:error, :not_found} ->
        Logger.info("Cache miss, fetching fresh exchange rate")
        fetch_and_cache_exchange_rate()
      
      {:error, _reason} ->
        Logger.warning("Cache error, falling back to API fetch")
        fetch_and_cache_exchange_rate()
    end
  end

  defp fetch_and_cache_exchange_rate do
    case fetch_exchange_rate_from_api() do
      {:ok, rate} ->
        # Cache the rate for future use
        Cache.set_currency_rate("IDR", "USD", rate)
        {:ok, rate}
      
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp fetch_exchange_rate_from_api do
    url = @base_url <> "IDR"
    
    Logger.info("Fetching exchange rate from API: #{url}")
    
    case HTTPoison.get(url, [], timeout: 5000, recv_timeout: 5000) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"rates" => %{"USD" => usd_rate}}} ->
            Logger.info("Successfully fetched exchange rate: #{usd_rate}")
            {:ok, usd_rate}
          
          _ ->
            Logger.error("Invalid API response format")
            {:error, :invalid_response}
        end
      
      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        Logger.error("API returned error status: #{status_code}")
        {:error, {:http_error, status_code}}
      
      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("HTTP request failed: #{inspect(reason)}")
        {:error, {:request_failed, reason}}
    end
  end
end