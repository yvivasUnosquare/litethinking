# 🚀 Quick Start with Docker

This guide will help you get the entire e-commerce application running with Docker in just a few minutes.

## Prerequisites

✅ Docker Desktop installed and running
✅ At least 4GB of free RAM
✅ Ports available: 3000, 8080, 8081, 8082, 5432, 5433

## Start the Application

### Option 1: Using Docker Compose (Recommended)

```bash
cd /Users/yelsonvivas/Documents/GitHub/ecommerce
docker-compose up -d --build
```

This will:
- Build all Docker images
- Start 6 containers (2 databases, 3 microservices, 1 web app)
- Configure networking between services
- Wait for health checks before starting dependent services

### Option 2: Using the Management Script

```bash
./docker-manage.sh start
```

## Check Status

```bash
# View running containers
docker-compose ps

# Check logs
docker-compose logs -f

# Check specific service logs
docker-compose logs -f product-service
docker-compose logs -f order-service
docker-compose logs -f api-gateway
docker-compose logs -f webapp
```

## Access the Application

Once all services are running (wait about 2-3 minutes for first startup):

| Service | URL | Description |
|---------|-----|-------------|
| **Web Application** | http://localhost:3000 | Main user interface |
| **API Gateway** | http://localhost:8080 | API entry point |
| **Product Service** | http://localhost:8081 | Product management |
| **Order Service** | http://localhost:8082 | Order management |
| **Product DB** | localhost:5432 | PostgreSQL database |
| **Order DB** | localhost:5433 | PostgreSQL database |

## Test the Application

### 1. Via Web Browser
Open http://localhost:3000 and:
- Browse products
- Add items to cart
- Create an order

### 2. Via API Gateway

```bash
# Get all products
curl http://localhost:8080/api/products

# Create a product
curl -X POST http://localhost:8080/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Laptop",
    "description": "High-performance laptop",
    "category": "Electronics",
    "price": 999.99,
    "stock": 50
  }'

# Get product by ID
curl http://localhost:8080/api/products/1

# Create an order
curl -X POST http://localhost:8080/api/orders \
  -H "Content-Type: application/json" \
  -d '{
    "customerName": "John Doe",
    "customerEmail": "john@example.com",
    "items": [
      {
        "productId": 1,
        "quantity": 2
      }
    ]
  }'

# Get all orders
curl http://localhost:8080/api/orders
```

## Stop the Application

```bash
# Stop all services
docker-compose down

# Stop and remove volumes (clean restart)
docker-compose down -v

# Or use the management script
./docker-manage.sh stop
./docker-manage.sh clean
```

## Troubleshooting

### Services not starting?

Check individual service logs:
```bash
docker-compose logs product-service
docker-compose logs order-service
docker-compose logs api-gateway
```

### Port already in use?

Stop other services using the same ports or modify ports in `docker-compose.yml`:
```yaml
ports:
  - "NEW_PORT:CONTAINER_PORT"
```

### Containers keep restarting?

Wait for health checks to pass. First startup takes 2-3 minutes. Check:
```bash
docker-compose ps
```

All services should show "Up (healthy)" status.

### Database connection errors?

Ensure PostgreSQL containers are healthy:
```bash
docker-compose logs postgres-product
docker-compose logs postgres-order
```

### Need a clean restart?

```bash
docker-compose down -v
docker-compose up -d --build
```

## API Documentation

Swagger UI is available for each service:

- Product Service: http://localhost:8081/swagger-ui.html
- Order Service: http://localhost:8082/swagger-ui.html

## Architecture

```
┌─────────────┐
│   Browser   │
└──────┬──────┘
       │
       │ :3000
       ▼
┌─────────────┐
│   Webapp    │
│  (Nginx)    │
└──────┬──────┘
       │
       │ :8080
       ▼
┌─────────────┐
│ API Gateway │
└──────┬──────┘
       │
       ├──────────────┬──────────────┐
       │              │              │
       ▼              ▼              │
┌─────────────┐ ┌─────────────┐    │
│  Product    │ │   Order     │    │
│  Service    │ │  Service    │◄───┘
└──────┬──────┘ └──────┬──────┘
       │                │
       ▼                ▼
┌─────────────┐ ┌─────────────┐
│ PostgreSQL  │ │ PostgreSQL  │
│  :5432      │ │  :5433      │
└─────────────┘ └─────────────┘
```

## What's Running?

| Container | Image | Purpose |
|-----------|-------|---------|
| postgres-product | postgres:15-alpine | Product database |
| postgres-order | postgres:15-alpine | Order database |
| product-service | Custom (Java 21) | Product CRUD operations |
| order-service | Custom (Java 21) | Order processing with Feign |
| api-gateway | Custom (Java 21) | Gateway with Circuit Breaker |
| webapp | Custom (Node 20 + Nginx) | React frontend |

## Management Commands

```bash
# Start all services
./docker-manage.sh start

# Stop all services
./docker-manage.sh stop

# Restart services
./docker-manage.sh restart

# View status
./docker-manage.sh status

# View logs
./docker-manage.sh logs
./docker-manage.sh logs product-service

# Clean restart (removes data)
./docker-manage.sh clean
```

## Performance Tips

- First build takes 5-10 minutes (downloads dependencies)
- Subsequent starts take 1-2 minutes
- Use `docker-compose build --parallel` for faster builds
- Allocate at least 4GB RAM to Docker Desktop

## Production Deployment

For production, consider:
- Using environment files for secrets
- Enabling HTTPS/TLS
- Adding monitoring (Prometheus/Grafana)
- Using managed databases
- Implementing CI/CD pipeline
- Adding logging aggregation

## Next Steps

1. ✅ Start the application
2. ✅ Test the Web UI at http://localhost:3000
3. ✅ Test the API at http://localhost:8080
4. ✅ Check Swagger docs
5. ✅ Review logs for any errors

## Support

For detailed documentation, see:
- [DOCKER_README.md](DOCKER_README.md) - Complete Docker guide
- [README.md](README.md) - Project overview
- [ARCHITECTURE.md](ARCHITECTURE.md) - Architecture details

---

🎉 **Your e-commerce platform is now running with Docker!**

