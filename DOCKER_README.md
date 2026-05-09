# Docker Deployment Guide

This guide explains how to run the entire e-commerce application using Docker and Docker Compose.

## Prerequisites

- Docker Desktop 4.0+ (includes Docker Compose V2)
- At least 4GB of free RAM
- At least 10GB of free disk space

## Architecture

The application consists of the following containers:

1. **postgres-product**: PostgreSQL database for Product Service (port 5432)
2. **postgres-order**: PostgreSQL database for Order Service (port 5433)
3. **product-service**: Product microservice (port 8081)
4. **order-service**: Order microservice (port 8082)
5. **api-gateway**: API Gateway (port 8080)
6. **webapp**: React frontend with Nginx (port 3000)

## Quick Start

### 1. Build and Start All Services

```bash
docker-compose up --build
```

This command will:
- Build Docker images for all services
- Start all containers in the correct order
- Wait for health checks to pass before starting dependent services

### 2. Run in Detached Mode (Background)

```bash
docker-compose up -d --build
```

### 3. View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f product-service
docker-compose logs -f order-service
docker-compose logs -f api-gateway
docker-compose logs -f webapp
```

### 4. Check Service Status

```bash
docker-compose ps
```

### 5. Stop All Services

```bash
docker-compose down
```

### 6. Stop and Remove Volumes (Clean Restart)

```bash
docker-compose down -v
```

## Access Points

Once all services are running:

- **Web Application**: http://localhost:3000
- **API Gateway**: http://localhost:8080
- **Product Service**: http://localhost:8081
- **Order Service**: http://localhost:8082
- **Product Database**: localhost:5432
- **Order Database**: localhost:5433

## API Documentation

- **Product Service Swagger UI**: http://localhost:8081/swagger-ui.html
- **Order Service Swagger UI**: http://localhost:8082/swagger-ui.html
- **API Gateway (via Gateway)**: http://localhost:8080/api/products, http://localhost:8080/api/orders

## Testing the Application

### Using the Web Interface

1. Open http://localhost:3000
2. Browse products
3. Add products to cart
4. Complete an order

### Using curl

```bash
# Get all products
curl http://localhost:8080/api/products

# Get product by ID
curl http://localhost:8080/api/products/1

# Create a product
curl -X POST http://localhost:8080/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Product",
    "description": "Test Description",
    "category": "Electronics",
    "price": 99.99,
    "stock": 10
  }'

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
```

## Troubleshooting

### Services Not Starting

Check logs for specific service:
```bash
docker-compose logs service-name
```

### Database Connection Issues

Ensure PostgreSQL containers are healthy:
```bash
docker-compose ps
```

Wait for health checks to pass (may take 30-60 seconds on first start).

### Port Conflicts

If ports are already in use, you can modify them in `docker-compose.yml`:
- Frontend: Change `3000:80` to `<new-port>:80`
- API Gateway: Change `8080:8080` to `<new-port>:8080`
- Product Service: Change `8081:8081` to `<new-port>:8081`
- Order Service: Change `8082:8082` to `<new-port>:8082`

### Rebuild After Code Changes

```bash
# Rebuild specific service
docker-compose build product-service

# Rebuild all services
docker-compose build

# Rebuild and restart
docker-compose up -d --build
```

### Clean Restart

```bash
# Stop all containers
docker-compose down

# Remove all volumes (database data will be lost)
docker-compose down -v

# Remove all images
docker-compose down --rmi all

# Start fresh
docker-compose up --build
```

## Environment Variables

All environment variables are configured in `docker-compose.yml`:

### Product Service
- `SPRING_PROFILES_ACTIVE=docker`
- `SPRING_DATASOURCE_URL=jdbc:postgresql://postgres-product:5432/product_db`
- `SPRING_DATASOURCE_USERNAME=postgres`
- `SPRING_DATASOURCE_PASSWORD=postgres`

### Order Service
- `SPRING_PROFILES_ACTIVE=docker`
- `SPRING_DATASOURCE_URL=jdbc:postgresql://postgres-order:5432/order_db`
- `SPRING_DATASOURCE_USERNAME=postgres`
- `SPRING_DATASOURCE_PASSWORD=postgres`
- `PRODUCT_SERVICE_URL=http://product-service:8081`

### API Gateway
- `PRODUCT_SERVICE_URL=http://product-service:8081`
- `ORDER_SERVICE_URL=http://order-service:8082`

## Health Checks

All services include health checks:

- **PostgreSQL**: Checked every 10s using `pg_isready`
- **Spring Boot Services**: Checked every 30s using `/actuator/health` endpoint
- **Start Period**: Services have 40-60s to fully start before health checks begin

## Volumes

Persistent data is stored in Docker volumes:

- `postgres-product-data`: Product database data
- `postgres-order-data`: Order database data

These volumes persist even after stopping containers. To remove them:
```bash
docker-compose down -v
```

## Network

All services communicate through a Docker bridge network called `ecommerce-network`. This allows services to communicate using container names as hostnames.

## Production Considerations

For production deployment:

1. **Security**:
   - Change default PostgreSQL passwords
   - Use environment files for secrets
   - Enable HTTPS/TLS
   - Implement authentication/authorization

2. **Performance**:
   - Adjust JVM heap size for Java services
   - Configure connection pools
   - Add Redis for caching
   - Use production-grade database

3. **Monitoring**:
   - Add Prometheus for metrics
   - Add Grafana for dashboards
   - Configure centralized logging
   - Set up alerts

4. **Scalability**:
   - Use Kubernetes for orchestration
   - Configure horizontal pod autoscaling
   - Use managed database services
   - Implement load balancing

## Support

For issues or questions, check:
- Service logs: `docker-compose logs -f <service-name>`
- Container status: `docker-compose ps`
- Health endpoints: `http://localhost:<port>/actuator/health`

