defmodule ProductApi.Currency do
  @moduledoc """
  Module for currency conversion operations.
  """

  require Logger

  @base_url "https://api.exchangerate-api.com/v4/latest/"

  @doc """
  Convert IDR to USD using real-time exchange rates.
  
  ## Examples
  
      iex> convert_idr_to_usd(50000)
      {:ok, 3.33}
      
      iex> convert_idr_to_usd(invalid)
      {:error, :conversion_failed}
  """
  def convert_idr_to_usd(idr_amount) when is_number(idr_amount) do
    case get_exchange_rate() do
      {:ok, rate} ->
        usd_amount = idr_amount * rate
        {:ok, Float.round(usd_amount, 2)}
      
      {:error, reason} ->
        Logger.warning("Currency conversion failed: #{inspect(reason)}")
        {:error, :conversion_failed}
    end
  end

  def convert_idr_to_usd(_), do: {:error, :invalid_amount}

  defp get_exchange_rate do
    url = @base_url <> "IDR"
    
    case HTTPoison.get(url, [], timeout: 5000, recv_timeout: 5000) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"rates" => %{"USD" => usd_rate}}} ->
            {:ok, usd_rate}
          
          _ ->
            {:error, :invalid_response}
        end
      
      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, {:http_error, status_code}}
      
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, {:request_failed, reason}}
    end
  end
end