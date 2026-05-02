#!/bin/bash

# Script para limpiar todo

echo "Stopping and removing containers..."

docker-compose down -v

echo "Removing local database containers..."
docker rm -f postgres-product postgres-order 2>/dev/null || true

echo "Cleaning build artifacts..."
./gradlew clean

rm -rf frontend/node_modules
rm -rf frontend/build

echo "Cleanup completed!"

