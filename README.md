# Product Management API - Phoenix Framework

REST API sederhana untuk mengelola produk dengan fungsionalitas CRUD, pagination, dan currency conversion yang dibuat menggunakan Phoenix Framework.

## 🚀 Features

- ✅ **CRUD Operations** - Create, Read, Update, Delete products
- ✅ **Validation** - Name uniqueness, positive price validation
- ✅ **Pagination** - 10 products per page with navigation
- ✅ **Currency Conversion** - Real-time IDR to USD conversion
- ✅ **High-Performance Caching** - Product and currency rate caching
- ✅ **Error Handling** - Comprehensive validation error responses
- ✅ **Database Persistence** - PostgreSQL with proper constraints
- ✅ **Cache Invalidation** - Smart cache management on updates

## 📋 API Endpoints

### 1. Create Product

**POST** `/api/products`

**Request Body:**

```json
{
  "name": "Product Name",
  "price_idr": 50000
}
```

**Response (201 Created):**

```json
{
  "data": {
    "id": 1,
    "name": "Product Name",
    "price_idr": "50000.00",
    "price_usd": 3.05
  }
}
```

**Validation Errors (422 Unprocessable Entity):**

```json
{
  "errors": {
    "name": ["can't be blank", "has already been taken"],
    "price_idr": ["must be greater than 0"]
  }
}
```

### 2. List Products (with Pagination)

**GET** `/api/products`  
**GET** `/api/products?page=2`

**Response (200 OK):**

```json
{
  "data": [
    {
      "id": 1,
      "name": "Product Name",
      "price_idr": "50000.00",
      "inserted_at": "2025-06-01T11:08:35Z",
      "updated_at": "2025-06-01T11:08:35Z"
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 10,
    "total": 25,
    "total_pages": 3
  }
}
```

### 3. Get Product Detail (with Currency Conversion)

**GET** `/api/products/{id}`

**Response (200 OK):**

```json
{
  "data": {
    "id": 1,
    "name": "Product Name",
    "price_idr": "50000.00",
    "price_usd": 3.05
  }
}
```

**Error (404 Not Found):**

```json
{
  "error": "Product not found"
}
```

### 4. Update Product

**PUT/PATCH** `/api/products/{id}`

**Request Body:**

```json
{
  "name": "Updated Product Name",
  "price_idr": 75000
}
```

### 5. Delete Product

**DELETE** `/api/products/{id}`

**Response:** 204 No Content

## 🛠 Tech Stack

- **Phoenix Framework** 1.7.21 (Elixir)
- **Ecto** - Database ORM
- **PostgreSQL** - Database
- **HTTPoison** - HTTP client for currency API
- **Cachex** - High-performance caching system
- **ExchangeRate-API** - Currency conversion service

## 📦 Installation & Setup

### Prerequisites

- Elixir 1.14+
- Erlang/OTP 25+
- PostgreSQL 12+
- Phoenix Framework 1.7+

### macOS Installation

```bash
# Install Elixir via Homebrew
brew install elixir

# Install Phoenix Framework
mix archive.install hex phx_new

# Verify installations
elixir --version
mix phx.new --version
postgres --version
```

### Project Setup

```bash
# Clone repository
git clone https://github.com/ykkhmrdn/product_api.git
cd product_api

# Install dependencies
mix deps.get

# Setup database
mix ecto.create
mix ecto.migrate

# Start development server
mix phx.server
```

Server akan berjalan di: `http://localhost:4000`

## 🔧 Configuration

### Database Configuration

Edit `config/dev.exs` jika diperlukan:

```elixir
config :product_api, ProductApi.Repo,
  username: "your_username",
  password: "your_password",
  hostname: "localhost",
  database: "product_api_dev"
```

### Environment Variables

Tidak ada environment variables khusus yang diperlukan. Currency API menggunakan free tier dari ExchangeRate-API.

## 🧪 Testing

### Manual Testing dengan cURL

**Create Product:**

```bash
curl -X POST http://localhost:4000/api/products \
  -H "Content-Type: application/json" \
  -d '{"name": "Test Product", "price_idr": 50000}'
```

**List Products:**

```bash
curl http://localhost:4000/api/products
```

**Get Product with Currency Conversion:**

```bash
curl http://localhost:4000/api/products/1
```

**Test Pagination:**

```bash
curl http://localhost:4000/api/products?page=2
```

**Test Cache Performance:**

```bash
# First request (cache miss) - slower
time curl http://localhost:4000/api/products/1

# Second request (cache hit) - much faster
time curl http://localhost:4000/api/products/1
```

### Validation Testing

**Test Empty Name:**

```bash
curl -X POST http://localhost:4000/api/products \
  -H "Content-Type: application/json" \
  -d '{"name": "", "price_idr": 50000}'
```

**Test Negative Price:**

```bash
curl -X POST http://localhost:4000/api/products \
  -H "Content-Type: application/json" \
  -d '{"name": "Test", "price_idr": -1000}'
```

**Test Duplicate Name:**

```bash
curl -X POST http://localhost:4000/api/products \
  -H "Content-Type: application/json" \
  -d '{"name": "Test Product", "price_idr": 60000}'
```

### Unit Tests

```bash
mix test
```

## 📊 Database Schema

```sql
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE,
  price_idr DECIMAL(15,2) NOT NULL CHECK (price_idr > 0),
  inserted_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE UNIQUE INDEX products_name_index ON products (name);
CREATE INDEX products_inserted_at_index ON products (inserted_at);
```

## 🏗 Project Structure

```
product_api/
├── lib/
│   ├── product_api/
│   │   ├── products/
│   │   │   ├── product.ex          # Product schema
│   │   │   └── products.ex         # Products context with caching
│   │   ├── currency.ex             # Currency conversion with caching
│   │   ├── cache.ex                # Cache management module
│   │   ├── application.ex          # Supervision tree with cache processes
│   │   └── repo.ex                 # Database repository
│   └── product_api_web/
│       ├── controllers/
│       │   ├── product_controller.ex
│       │   ├── product_json.ex
│       │   ├── changeset_json.ex
│       │   └── fallback_controller.ex
│       └── router.ex               # API routes
├── priv/repo/migrations/
│   └── *_create_products.exs
├── config/
├── test/
└── README.md
```

## 🔍 Currency Conversion

API menggunakan [ExchangeRate-API](https://exchangerate-api.com/) untuk konversi real-time IDR ke USD:

- **Endpoint:** `https://api.exchangerate-api.com/v4/latest/IDR`
- **Free Tier:** 1,500 requests/month
- **Timeout:** 5 detik
- **Caching:** Currency rates cached for 15 minutes
- **Fallback:** Jika conversion gagal, price_usd akan null

## 🚀 High-Performance Caching System

### Cache Features

- **Product Caching:** Products cached for 5 minutes
- **Currency Rate Caching:** Exchange rates cached for 15 minutes
- **Smart Invalidation:** Cache automatically invalidated on updates
- **Performance Boost:** Up to 6,500x faster response times

### Cache Statistics

- **Without Cache:** ~1300ms (database + API calls)
- **With Cache:** ~200µs (microseconds!)
- **Cache Hit Rate:** 100% after initial load
- **Memory Efficient:** LRU eviction with configurable limits

### Cache Management

```bash
# View cache statistics (in IEx console)
iex> ProductApi.Cache.get_cache_stats()

# Clear all caches (development only)
iex> ProductApi.Cache.clear_all_caches()
```

## ⚠️ Error Handling

### HTTP Status Codes

- **200** - Success
- **201** - Created
- **204** - No Content (for delete)
- **404** - Not Found
- **422** - Unprocessable Entity (validation errors)

### Error Response Format

```json
{
  "errors": {
    "field_name": ["error message"]
  }
}
```

## 🚀 Deployment Notes

### Production Setup

```bash
# Set environment
export MIX_ENV=prod

# Install dependencies
mix deps.get --only prod

# Compile assets
mix assets.deploy

# Run migrations
mix ecto.migrate

# Start server
mix phx.server
```

### Database Migration

```bash
mix ecto.create
mix ecto.migrate
```

## 📈 Performance Considerations

- **Pagination:** Limit 10 items per page untuk performa optimal
- **Database Indexes:** Index pada name (unique) dan inserted_at
- **Caching Strategy:**
  - Product cache: 5 minutes TTL with LRU eviction (1000 items limit)
  - Currency cache: 15 minutes TTL with LRU eviction (100 items limit)
- **Cache Invalidation:** Automatic invalidation on product updates/deletes
- **Connection Pooling:** Ecto pool default 10 connections
- **API Rate Limiting:** Currency API calls reduced by 95%+ via caching

## 🤝 Contributing

1. Fork repository
2. Create feature branch
3. Commit changes with descriptive messages
4. Push to branch
5. Create Pull Request

## 📝 License

This project is created for technical assessment purposes.

---

**Developed by:** zyxkoo
**Framework:** Phoenix Framework (Elixir)  
**Database:** PostgreSQL  
**API Version:** v1
