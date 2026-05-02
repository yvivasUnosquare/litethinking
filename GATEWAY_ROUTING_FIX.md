# 🔧 SOLUCIÓN: Docker I/O Error y Gateway Routing

## ❌ Problemas Encontrados

1. **Docker I/O Error**: `input/output error` en Docker buildkit
2. **Gateway Routing**: Rutas no funcionan debido a context-path

## ✅ Soluciones

### Solución 1: Reiniciar Docker Desktop (Para I/O Error)

```bash
# 1. Detener servicios
docker compose down -v

# 2. Salir de Docker Desktop completamente
# Mac: Docker Desktop > Quit Docker Desktop

# 3. Abrir Docker Desktop de nuevo

# 4. Esperar 30 segundos

# 5. Intentar de nuevo
docker compose up --build
```

### Solución 2: Remover Context-Path (Más Simple)

La mejor solución es **eliminar el context-path** de los microservicios para simplificar el ruteo.

#### Actualizar Product Service

**Archivo**: `product-service/src/main/resources/application.yml`

```yaml
server:
  port: 8081
  servlet:
    context-path: /  # Cambiar de /product-service a /
```

#### Actualizar Order Service  

**Archivo**: `order-service/src/main/resources/application.yml`

```yaml
server:
  port: 8082
  servlet:
    context-path: /  # Cambiar de /order-service a /
```

#### Actualizar API Gateway

**Archivo**: `api-gateway/src/main/resources/application.yml`

```yaml
routes:
  - id: product-service
    uri: http://product-service:8081  # Sin /product-service al final
    predicates:
      - Path=/api/products/**
    filters:
      - name: CircuitBreaker
        args:
          name: productServiceCB
          fallbackUri: forward:/api/fallback/products
          
  - id: order-service
    uri: http://order-service:8082  # Sin /order-service al final
    predicates:
      - Path=/api/orders/**
    filters:
      - name: CircuitBreaker
        args:
          name: orderServiceCB
          fallbackUri: forward:/api/fallback/orders
```

## 🚀 Aplicar Solución Simplificada

Voy a aplicar la Solución 2 automáticamente porque es más robusta y evita problemas de ruteo.

## 📋 Alternativa: Path Rewriting (Ya Aplicado)

Si prefieres mantener el context-path, usa RewritePath filter (ya está en el código):

```yaml
filters:
  - name: CircuitBreaker
    args:
      name: productServiceCB
  - RewritePath=/api/products/(?<segment>.*), /product-service/api/products/$\{segment}
```

## 🔍 Verificar Docker Health

```bash
# Ver estadísticas de Docker
docker system df

# Ver info de Docker
docker info | grep -i "storage\|error"

# Si ves errores de I/O, reinicia Docker Desktop
```

## 📊 Comparación de Enfoques

| Enfoque | Pros | Contras |
|---------|------|---------|
| Sin context-path | Simple, directo, fácil de debuggear | URLs menos específicas |
| Con context-path | URLs más descriptivas | Complica el ruteo, requiere RewritePath |

**Recomendación**: **Sin context-path** para microservicios (más simple y estándar)

## ✅ Próximos Pasos

1. Eliminar context-path de los servicios
2. Simplificar configuración del Gateway
3. Reconstruir todo
4. Verificar que funciona

---

**Estado**: En progreso  
**Solución aplicada**: RewritePath filters  
**Próxima acción**: Remover context-paths (más simple)

