defmodule ProductApi.Repo do
  use Ecto.Repo,
    otp_app: :product_api,
    adapter: Ecto.Adapters.Postgres
end
