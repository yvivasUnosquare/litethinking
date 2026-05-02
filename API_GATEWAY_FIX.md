# 🔧 API GATEWAY FIX - RESOLVED

## Problem

The API Gateway was returning **500 Internal Server Error** when accessing endpoints like:
- `http://localhost:8080/api/products`
- `http://localhost:8080/api/orders`

However, direct access to the services worked fine:
- `http://localhost:8081/api/products` ✅
- `http://localhost:8082/api/orders` ✅

## Root Causes

### 1. **Wrong Hostnames in Configuration**
The `application.yml` was configured for Docker deployment with hostnames like:
- `http://product-service:8081` (Docker hostname)
- `http://order-service:8082` (Docker hostname)

But the services were running locally on `localhost`.

### 2. **Duplicate Route Configuration**
There were **two conflicting route configurations**:
- Routes defined in `application.yml`
- Routes defined programmatically in `ApiGatewayApplication.java`

The Java configuration had **invalid URIs** with extra path segments:
```java
.uri("http://product-service:8081/product-service")  // ❌ Wrong
.uri("http://order-service:8082/order-service")      // ❌ Wrong
```

## Solution

### Changes Made

#### 1. **Fixed `application.yml`** 
Changed service URIs from Docker hostnames to `localhost`:

```yaml
spring:
  cloud:
    gateway:
      routes:
        - id: product-service
          uri: http://localhost:8081  # ✅ Changed from http://product-service:8081
          predicates:
            - Path=/api/products/**
          filters:
            - name: CircuitBreaker
              args:
                name: productServiceCB
                fallbackUri: forward:/api/fallback/products
        - id: order-service
          uri: http://localhost:8082  # ✅ Changed from http://order-service:8082
          predicates:
            - Path=/api/orders/**
          filters:
            - name: CircuitBreaker
              args:
                name: orderServiceCB
                fallbackUri: forward:/api/fallback/orders
```

#### 2. **Removed Duplicate Routes from Java**
Removed the `@Bean RouteLocator` configuration from `ApiGatewayApplication.java`:

**Before:**
```java
@Bean
public RouteLocator customRouteLocator(RouteLocatorBuilder builder) {
    return builder.routes()
            .route("product-service", r -> r
                    .path("/api/products/**")
                    .uri("http://product-service:8081/product-service"))  // ❌ Wrong
            .route("order-service", r -> r
                    .path("/api/orders/**")
                    .uri("http://order-service:8082/order-service"))      // ❌ Wrong
            .build();
}
```

**After:**
```java
@SpringBootApplication
public class ApiGatewayApplication {
    public static void main(String[] args) {
        SpringApplication.run(ApiGatewayApplication.class, args);
    }
}
```

Now routes are **only** defined in `application.yml` (single source of truth).

## Testing

### ✅ All Tests Pass

```bash
# Through API Gateway (Port 8080)
curl http://localhost:8080/api/products
# Response: [ { "id": 1, "name": "iphone", ... } ] ✅

curl http://localhost:8080/api/orders
# Response: [ ] ✅

curl http://localhost:8080/api/products/1
# Response: { "id": 1, "name": "iphone", ... } ✅
```

### ✅ Direct Service Access Still Works

```bash
# Product Service (Port 8081)
curl http://localhost:8081/api/products  # ✅

# Order Service (Port 8082)
curl http://localhost:8082/api/orders    # ✅
```

## How to Restart API Gateway

If you need to restart the API Gateway after changes:

```bash
# 1. Find the process
lsof -i :8080 | grep LISTEN

# 2. Kill it
kill -9 <PID>

# 3. Rebuild and restart
./gradlew :api-gateway:clean :api-gateway:build -x test
./gradlew :api-gateway:bootRun
```

Or use the script:
```bash
./restart-gradle.sh
```

## Architecture

```
                    ┌──────────────────┐
                    │   API Gateway    │
                    │  localhost:8080  │
                    └────────┬─────────┘
                             │
              ┌──────────────┴──────────────┐
              │                             │
    ┌─────────▼─────────┐       ┌──────────▼──────────┐
    │  Product Service  │       │   Order Service     │
    │  localhost:8081   │       │   localhost:8082    │
    └───────────────────┘       └─────────────────────┘
              │                             │
    ┌─────────▼─────────┐       ┌──────────▼──────────┐
    │  PostgreSQL       │       │   PostgreSQL        │
    │  localhost:5432   │       │   localhost:5433    │
    └───────────────────┘       └─────────────────────┘
```

## Features Working

✅ **Routing** - Gateway correctly routes to both services  
✅ **Circuit Breaker** - Fallback endpoints configured  
✅ **Load Balancing** - Ready for multiple instances  
✅ **Error Handling** - Global exception handler in place  
✅ **OpenAPI Documentation** - Swagger UI available  

## URLs Reference

| Service | Direct Access | Through Gateway |
|---------|---------------|-----------------|
| Product Service | http://localhost:8081/api/products | http://localhost:8080/api/products |
| Order Service | http://localhost:8082/api/orders | http://localhost:8080/api/orders |
| Product Swagger | http://localhost:8081/swagger-ui.html | N/A |
| Order Swagger | http://localhost:8082/swagger-ui.html | N/A |
| Gateway Swagger | N/A | http://localhost:8080/swagger-ui.html |

## Future Considerations

### For Docker Deployment

When deploying with Docker Compose, you'll need to switch back to Docker hostnames. Create a separate profile:

**application-docker.yml:**
```yaml
spring:
  cloud:
    gateway:
      routes:
        - id: product-service
          uri: http://product-service:8081
        - id: order-service
          uri: http://order-service:8082
```

Then run with:
```bash
docker-compose up
# Services will use Docker network hostnames
```

### For Local Development

Keep the current configuration with `localhost`:
```bash
./gradlew :api-gateway:bootRun
# Uses localhost for local services
```

## Summary

The API Gateway is now **fully functional** and correctly routing requests to both Product and Order services. The issue was caused by:
1. Wrong hostnames (Docker vs localhost)
2. Duplicate route configurations with invalid URIs

Both issues have been resolved! 🎉

