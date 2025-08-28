# E-commerce Cart API

API REST para gerenciamento de carrinho de compras desenvolvida em Ruby on Rails com funcionalidades completas de CRUD, controle de estoque e gerenciamento de carrinhos abandonados.

## Tecnologias

- Ruby 3.3.1
- Rails 7.1.3.2
- PostgreSQL 16
- Redis 7.0.15
- Sidekiq
- RSpec
- Docker

## Funcionalidades

- Adicionar/remover produtos do carrinho
- Atualizar quantidades
- Controle de estoque
- Gerenciamento de sessão
- Jobs para carrinhos abandonados
- 187 testes com 100% de cobertura

## API Endpoints

### Carrinho
- `GET /api/v1/cart` - Lista itens do carrinho
- `POST /api/v1/cart/add_item` - Adiciona produto
- `PUT /api/v1/cart/:product_id` - Atualiza quantidade
- `DELETE /api/v1/cart/:product_id` - Remove produto
- `DELETE /api/v1/cart` - Limpa carrinho

### Produtos
- `GET /api/v1/products` - Lista produtos disponíveis

## Execução com Docker

```bash
# Clone e acesse o diretório
git clone https://github.com/Renzo-Tognella/marketplace_project.git
cd marketplace_project

# Execute com Docker
docker-compose up --build

# Configure o banco
docker-compose exec web rails db:create db:migrate db:seed

# Execute os testes
docker-compose exec test rspec
```

## Execução Local

```bash
# Instale dependências
bundle install

# Configure banco
rails db:create db:migrate db:seed

# Inicie serviços
redis-server
bundle exec sidekiq
bundle exec rails server

# Execute testes
bundle exec rspec
```

## Monitoramento

- Aplicação: `http://localhost:3000`
- Sidekiq UI: `http://localhost:3000/sidekiq`

## Arquitetura

- **Models**: Cart, CartItem, Product
- **Services**: Carts::AddItem, RemoveItem, UpdateQuantity, Clear, MarkAsAbandoned
- **Controllers**: Api::V1::CartsController, ProductsController
- **Jobs**: MarkAsAbandonedJob, RemoveAbandonedJob
- **Serializers**: CartSerializer, ProductSerializer

---

**Desenvolvido com Ruby on Rails**
