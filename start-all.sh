#!/bin/bash

# 🚀 Quick Start Script for E-Commerce Platform
# This script starts all services in the correct order

echo "🚀 Starting E-Commerce Platform"
echo "================================"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if PostgreSQL containers are running
echo -e "${YELLOW}1. Checking PostgreSQL containers...${NC}"
if ! docker ps | grep -q postgres-product; then
    echo "Starting PostgreSQL for Product Service..."
    docker run -d --name postgres-product \
      -e POSTGRES_DB=product_db \
      -e POSTGRES_USER=postgres \
      -e POSTGRES_PASSWORD=postgres \
      -p 5432:5432 \
      postgres:15-alpine
fi

if ! docker ps | grep -q postgres-order; then
    echo "Starting PostgreSQL for Order Service..."
    docker run -d --name postgres-order \
      -e POSTGRES_DB=order_db \
      -e POSTGRES_USER=postgres \
      -e POSTGRES_PASSWORD=postgres \
      -p 5433:5432 \
      postgres:15-alpine
fi

echo -e "${GREEN}✓ PostgreSQL containers ready${NC}"
echo ""

# Wait for databases to be ready
echo "Waiting for databases to initialize (10 seconds)..."
sleep 10
echo ""

# Build the project
echo -e "${YELLOW}2. Building services...${NC}"
./gradlew clean build -x test
echo -e "${GREEN}✓ Build complete${NC}"
echo ""

# Start services in background
echo -e "${YELLOW}3. Starting microservices...${NC}"
echo ""

echo "Starting Product Service on port 8081..."
./gradlew :product-service:bootRun > /tmp/product-service.log 2>&1 &
PRODUCT_PID=$!
sleep 5

echo "Starting Order Service on port 8082..."
./gradlew :order-service:bootRun > /tmp/order-service.log 2>&1 &
ORDER_PID=$!
sleep 5

echo "Starting API Gateway on port 8080..."
./gradlew :api-gateway:bootRun > /tmp/api-gateway.log 2>&1 &
GATEWAY_PID=$!
sleep 10

echo -e "${GREEN}✓ All services started${NC}"
echo ""

# Test services
echo -e "${YELLOW}4. Testing services...${NC}"
echo ""

if curl -s http://localhost:8081/actuator/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Product Service (8081) - Ready${NC}"
else
    echo "✗ Product Service not responding"
    echo "  Check logs: tail -f /tmp/product-service.log"
fi

if curl -s http://localhost:8082/actuator/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Order Service (8082) - Ready${NC}"
else
    echo "✗ Order Service not responding"
    echo "  Check logs: tail -f /tmp/order-service.log"
fi

if curl -s http://localhost:8080/actuator/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓ API Gateway (8080) - Ready${NC}"
else
    echo "✗ API Gateway not responding"
    echo "  Check logs: tail -f /tmp/api-gateway.log"
fi

echo ""
echo "================================"
echo -e "${GREEN}✅ Platform Started Successfully!${NC}"
echo ""
echo "📋 Next Steps:"
echo ""
echo "  1. Start the WebApp:"
echo "     cd webapp && npm run dev"
echo ""
echo "  2. Access the application:"
echo "     • WebApp:         http://localhost:5173"
echo "     • API Gateway:    http://localhost:8080"
echo "     • Product API:    http://localhost:8081/api/products"
echo "     • Order API:      http://localhost:8082/api/orders"
echo ""
echo "  3. View logs:"
echo "     • Product:  tail -f /tmp/product-service.log"
echo "     • Order:    tail -f /tmp/order-service.log"
echo "     • Gateway:  tail -f /tmp/api-gateway.log"
echo ""
echo "  4. Stop services:"
echo "     ./stop-local.sh"
echo ""
echo "🎉 Happy Shopping!"

