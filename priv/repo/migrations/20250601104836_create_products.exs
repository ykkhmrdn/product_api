defmodule ProductApi.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :name, :string, null: false
      add :price_idr, :decimal, precision: 15, scale: 2, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:products, [:name])
    create constraint(:products, :price_idr_must_be_positive, check: "price_idr > 0")
    create index(:products, [:inserted_at])
  end
end