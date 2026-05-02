#!/bin/bash

# Script para verificar que Docker Compose está configurado correctamente

# Detectar comando de docker compose
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
elif command -v docker &> /dev/null && docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
else
    echo "❌ Error: Docker Compose no está instalado"
    exit 1
fi

echo "🔍 Verificando configuración de Docker Compose..."
echo "   Usando: $DOCKER_COMPOSE"
echo ""

# Verificar que docker-compose.yml existe
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Error: docker-compose.yml no encontrado"
    exit 1
fi

echo "✅ docker-compose.yml encontrado"

# Verificar sintaxis de docker-compose.yml
echo ""
echo "🔍 Verificando sintaxis..."
if $DOCKER_COMPOSE config > /dev/null 2>&1; then
    echo "✅ Sintaxis correcta"
else
    echo "❌ Error en sintaxis de docker-compose.yml"
    $DOCKER_COMPOSE config
    exit 1
fi

# Verificar que todos los servicios tienen la red configurada
echo ""
echo "🔍 Verificando configuración de red..."

SERVICES=("postgres-product" "postgres-order" "product-service" "order-service" "api-gateway")
ALL_OK=true

for service in "${SERVICES[@]}"; do
    if $DOCKER_COMPOSE config | grep -A 10 "^  $service:" | grep -q "ecommerce-network"; then
        echo "✅ $service está en ecommerce-network"
    else
        echo "❌ $service NO está en ecommerce-network"
        ALL_OK=false
    fi
done

if [ "$ALL_OK" = false ]; then
    echo ""
    echo "❌ Algunos servicios no están configurados correctamente"
    exit 1
fi

# Verificar que Docker está ejecutándose
echo ""
echo "🔍 Verificando Docker daemon..."
if docker info > /dev/null 2>&1; then
    echo "✅ Docker está ejecutándose"
else
    echo "❌ Docker no está ejecutándose. Por favor inicia Docker Desktop"
    exit 1
fi

# Verificar versión de Docker Compose
echo ""
echo "🔍 Verificando versión de Docker Compose..."
if [ "$DOCKER_COMPOSE" = "docker-compose" ]; then
    COMPOSE_VERSION=$($DOCKER_COMPOSE version --short 2>/dev/null || echo "0.0.0")
else
    COMPOSE_VERSION=$($DOCKER_COMPOSE version --short 2>/dev/null || echo "0.0.0")
fi
echo "   Versión: $COMPOSE_VERSION"

if [ "$COMPOSE_VERSION" != "0.0.0" ]; then
    echo "✅ Docker Compose instalado"
else
    echo "❌ Docker Compose no encontrado"
    exit 1
fi

# Verificar puertos disponibles
echo ""
echo "🔍 Verificando puertos disponibles..."
PORTS=(5432 5433 8080 8081 8082)
PORTS_OK=true

for port in "${PORTS[@]}"; do
    if lsof -i :$port > /dev/null 2>&1; then
        echo "⚠️  Puerto $port está en uso"
        echo "   Proceso: $(lsof -i :$port | tail -1 | awk '{print $1}')"
        PORTS_OK=false
    else
        echo "✅ Puerto $port está disponible"
    fi
done

if [ "$PORTS_OK" = false ]; then
    echo ""
    echo "⚠️  Algunos puertos están en uso. Ejecuta ./stop-local.sh para limpiar"
fi

# Resumen
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 RESUMEN DE VERIFICACIÓN"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ "$ALL_OK" = true ] && [ "$PORTS_OK" = true ]; then
    echo "✅ Todo está configurado correctamente"
    echo ""
    echo "🚀 Puedes iniciar los servicios con:"
    echo "   $DOCKER_COMPOSE up --build"
    echo ""
    exit 0
else
    echo "⚠️  Hay algunos problemas que debes resolver"
    echo ""
    if [ "$ALL_OK" = false ]; then
        echo "   1. Verifica que todos los servicios tengan 'networks: - ecommerce-network'"
    fi
    if [ "$PORTS_OK" = false ]; then
        echo "   2. Libera los puertos en uso ejecutando: ./stop-local.sh"
    fi
    echo ""
    exit 1
fi

