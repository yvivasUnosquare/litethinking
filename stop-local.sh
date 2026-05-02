#!/bin/bash

# Script para detener todos los servicios

# Detectar comando de docker compose
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
elif command -v docker &> /dev/null && docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
else
    DOCKER_COMPOSE="docker-compose"  # fallback
fi

echo "Stopping ecommerce platform..."

# Stop Docker Compose services
if $DOCKER_COMPOSE ps 2>/dev/null | grep -q "Up"; then
    echo "Stopping Docker Compose services..."
    $DOCKER_COMPOSE down
fi

# Stop local PostgreSQL containers
echo "Stopping local PostgreSQL containers..."
docker stop postgres-product postgres-order 2>/dev/null
docker rm postgres-product postgres-order 2>/dev/null

# Kill Gradle processes
echo "Stopping Gradle processes..."
pkill -f "gradlew.*bootRun" 2>/dev/null

# Kill Node processes
echo "Stopping Node processes..."
pkill -f "node.*vite" 2>/dev/null

echo "All services stopped."

