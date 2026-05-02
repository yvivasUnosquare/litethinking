#!/bin/bash

# Script para iniciar todos los servicios localmente

# Detectar comando de docker compose
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
elif command -v docker &> /dev/null && docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
else
    DOCKER_COMPOSE="docker-compose"  # fallback
fi

echo "Starting ecommerce platform..."
echo ""
echo "Choose deployment mode:"
echo "1) Docker Compose (recommended)"
echo "2) Local with Gradle"
echo ""
read -p "Enter your choice (1 or 2): " choice

case $choice in
    1)
        echo "Starting with Docker Compose..."
        echo "Using: $DOCKER_COMPOSE"

        # Check if Docker is running
        if ! docker info > /dev/null 2>&1; then
            echo "Error: Docker is not running. Please start Docker first."
            exit 1
        fi

        # Build and start all services
        $DOCKER_COMPOSE up --build
        ;;
    2)
        echo "Starting locally with Gradle..."

        # Check if Java is installed
        if ! command -v java &> /dev/null; then
            echo "Error: Java is not installed"
            exit 1
        fi

        # Check if PostgreSQL containers are running
        echo "Starting PostgreSQL databases..."
        docker run -d \
          --name postgres-product \
          -e POSTGRES_DB=product_db \
          -e POSTGRES_USER=postgres \
          -e POSTGRES_PASSWORD=postgres \
          -p 5432:5432 \
          postgres:15-alpine 2>/dev/null || echo "postgres-product already running"

        docker run -d \
          --name postgres-order \
          -e POSTGRES_DB=order_db \
          -e POSTGRES_USER=postgres \
          -e POSTGRES_PASSWORD=postgres \
          -p 5433:5432 \
          postgres:15-alpine 2>/dev/null || echo "postgres-order already running"

        sleep 5

        # Build all services
        echo "Building services..."
        ./gradlew build -x test

        # Start services in background
        echo "Starting services..."
        ./gradlew :product-service:bootRun &
        PRODUCT_PID=$!

        sleep 10

        ./gradlew :order-service:bootRun &
        ORDER_PID=$!

        sleep 10

        ./gradlew :api-gateway:bootRun &
        GATEWAY_PID=$!

        sleep 5

        # Start frontend if exists
        if [ -d "webapp" ]; then
            echo "Starting WebApp..."
            cd webapp
            npm install
            npm run dev &
            FRONTEND_PID=$!
            cd ..
        fi

        echo ""
        echo "=========================================="
        echo "All services are running..."
        echo "=========================================="
        echo "Frontend: http://localhost:5173"
        echo "API Gateway: http://localhost:8080"
        echo "Product Service: http://localhost:8081/swagger-ui.html"
        echo "Order Service: http://localhost:8082/swagger-ui.html"
        echo ""
        echo "Press Ctrl+C to stop all services"
        echo "=========================================="

        # Wait for all background jobs
        wait
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac
