# 🐳 Docker Commands Cheat Sheet

## Start/Stop Commands

```bash
# Start all services (build first time)
docker-compose up -d --build

# Start all services (use existing images)
docker-compose up -d

# Stop all services
docker-compose down

# Stop and remove volumes (clean restart)
docker-compose down -v

# Restart all services
docker-compose restart

# Restart specific service
docker-compose restart product-service
```

## Status & Monitoring

```bash
# Check running containers
docker-compose ps

# View logs (all services)
docker-compose logs -f

# View logs (specific service)
docker-compose logs -f product-service
docker-compose logs -f order-service
docker-compose logs -f api-gateway
docker-compose logs -f webapp

# View last 100 lines
docker-compose logs --tail=100 product-service

# Check service health
docker-compose ps | grep healthy
```

## Management Script

```bash
# Start
./docker-manage.sh start

# Stop
./docker-manage.sh stop

# Restart
./docker-manage.sh restart

# Status
./docker-manage.sh status

# Logs
./docker-manage.sh logs
./docker-manage.sh logs product-service

# Clean (remove everything)
./docker-manage.sh clean
```

## Building

```bash
# Build all images
docker-compose build

# Build specific service
docker-compose build product-service

# Build without cache
docker-compose build --no-cache

# Build in parallel
docker-compose build --parallel
```

## Troubleshooting

```bash
# Check Docker is running
docker info

# Run pre-flight checks
./docker-preflight.sh

# Check specific container
docker logs product-service

# Execute command in container
docker exec -it product-service sh

# Check container stats
docker stats

# Check networks
docker network ls

# Check volumes
docker volume ls

# Clean up unused resources
docker system prune -a
```

## Database Access

```bash
# Connect to product database
docker exec -it postgres-product psql -U postgres -d product_db

# Connect to order database
docker exec -it postgres-order psql -U postgres -d order_db

# Backup database
docker exec postgres-product pg_dump -U postgres product_db > backup.sql

# Restore database
docker exec -i postgres-product psql -U postgres product_db < backup.sql
```

## Testing Endpoints

```bash
# Health checks
curl http://localhost:8080/actuator/health
curl http://localhost:8081/actuator/health
curl http://localhost:8082/actuator/health

# Get all products
curl http://localhost:8080/api/products

# Get product by ID
curl http://localhost:8080/api/products/1

# Create product
curl -X POST http://localhost:8080/api/products \
  -H "Content-Type: application/json" \
  -d '{"name":"Laptop","description":"Gaming laptop","category":"Electronics","price":1299.99,"stock":50}'

# Update product
curl -X PUT http://localhost:8080/api/products/1 \
  -H "Content-Type: application/json" \
  -d '{"name":"Laptop Pro","description":"Updated description","category":"Electronics","price":1499.99,"stock":30}'

# Delete product
curl -X DELETE http://localhost:8080/api/products/1

# Get all orders
curl http://localhost:8080/api/orders

# Create order
curl -X POST http://localhost:8080/api/orders \
  -H "Content-Type: application/json" \
  -d '{"customerName":"John Doe","customerEmail":"john@example.com","items":[{"productId":1,"quantity":2}]}'

# Get order by ID
curl http://localhost:8080/api/orders/1

# Get orders by customer email
curl http://localhost:8080/api/orders/customer/john@example.com
```

## URLs

| Service | URL |
|---------|-----|
| Web App | http://localhost:3000 |
| API Gateway | http://localhost:8080 |
| Product Service | http://localhost:8081 |
| Order Service | http://localhost:8082 |
| Product Swagger | http://localhost:8081/swagger-ui.html |
| Order Swagger | http://localhost:8082/swagger-ui.html |

## Common Issues

### Port already in use
```bash
# Find process using port
lsof -i :3000
lsof -i :8080

# Kill process
kill -9 <PID>

# Or change port in docker-compose.yml
```

### Container won't start
```bash
# Check logs
docker-compose logs <service-name>

# Check health
docker-compose ps

# Restart container
docker-compose restart <service-name>

# Rebuild container
docker-compose build --no-cache <service-name>
docker-compose up -d <service-name>
```

### Database connection error
```bash
# Check PostgreSQL is running
docker-compose ps postgres-product postgres-order

# Check logs
docker-compose logs postgres-product

# Restart database
docker-compose restart postgres-product

# Clean restart
docker-compose down -v
docker-compose up -d
```

### Out of disk space
```bash
# Remove unused images
docker image prune -a

# Remove unused volumes
docker volume prune

# Remove everything unused
docker system prune -a --volumes
```

## Quick Scripts

### Full Clean & Restart
```bash
docker-compose down -v --rmi all
docker-compose up -d --build
```

### Update Single Service
```bash
docker-compose build product-service
docker-compose up -d --no-deps product-service
```

### View Resource Usage
```bash
docker stats --no-stream
```

### Export Logs
```bash
docker-compose logs > logs.txt
```

## Environment Variables

Edit `docker-compose.yml` to change:

```yaml
environment:
  SPRING_PROFILES_ACTIVE: docker
  SPRING_DATASOURCE_URL: jdbc:postgresql://postgres-product:5432/product_db
  SPRING_DATASOURCE_USERNAME: postgres
  SPRING_DATASOURCE_PASSWORD: postgres
  PRODUCT_SERVICE_URL: http://product-service:8081
```

## Tips

- Always use `-d` flag to run in background
- Use `--build` when code changes
- Check logs with `-f` flag to follow
- Use `docker-compose ps` to check status
- Run `./docker-preflight.sh` before starting
- Wait 2-3 minutes on first start
- Use `docker-compose down -v` for clean restart

---

**Quick Start:**
```bash
cd /Users/yelsonvivas/Documents/GitHub/ecommerce
docker-compose up -d --build
# Wait 2-3 minutes
open http://localhost:3000
```

