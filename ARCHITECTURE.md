# Arquitectura de E-commerce Microservicios

## Diagrama de Componentes

```
┌─────────────────────────────────────────────────────────────┐
│                         CLIENTE                             │
│                   (Navegador Web)                           │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    FRONTEND (React)                         │
│                    Puerto: 3000                             │
│  - Product Catalog     - Shopping Cart                      │
│  - Checkout            - Order Management                   │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                  API GATEWAY                                │
│                  Puerto: 8080                               │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ - Enrutamiento de requests                           │  │
│  │ - Circuit Breaker (Resilience4j)                     │  │
│  │ - Load Balancing                                     │  │
│  └──────────────────────────────────────────────────────┘  │
└────┬──────────────────────────────────────┬─────────────────┘
     │                                      │
     ▼                                      ▼
┌──────────────────────┐       ┌──────────────────────────────┐
│  PRODUCT SERVICE     │       │   ORDER SERVICE              │
│  Puerto: 8081        │       │   Puerto: 8082               │
├──────────────────────┤       ├──────────────────────────────┤
│ Endpoints:           │       │ Endpoints:                   │
│ GET    /products     │       │ GET    /orders               │
│ POST   /products     │       │ POST   /orders               │
│ PUT    /products/:id │       │ PUT    /orders/:id/status    │
│ DELETE /products/:id │       │ DELETE /orders/:id           │
│ POST   /:id/reserve  │       │                              │
│ POST   /:id/release  │       │ OpenFeign Client:            │
├──────────────────────┤       │ - ProductServiceClient       │
│ Features:            │       │ - Circuit Breaker            │
│ - CRUD Products      │       │ - Fallback methods           │
│ - Stock Management   │       │                              │
│ - Validation         │       │ Features:                    │
└──────┬───────────────┘       │ - Order Management           │
       │                       │ - Stock Reservation          │
       │                       │ - Order Status Updates       │
       │                       │ - Resilience to Failures     │
       │                       └──────┬──────────────────────┘
       │                              │
       └──────────────────┬───────────┘
                          │
        ┌─────────────────┴─────────────────┐
        │                                   │
        ▼                                   ▼
    ┌────────────────┐               ┌────────────────┐
    │ PostgreSQL     │               │ PostgreSQL     │
    │ product_db     │               │ order_db       │
    │ Puerto: 5432   │               │ Puerto: 5433   │
    │ - Products     │               │ - Orders       │
    │ - Stock Levels │               │ - Order Items  │
    └────────────────┘               └────────────────┘
```

## Patrones de Comunicación

### 1. Cliente a Gateway (HTTP/REST)
```
GET /api/products
↓ (Gateway enruta)
GET http://product-service:8081/product-service/api/products
```

### 2. Inter-servicios (OpenFeign + Circuit Breaker)
```
Order Service
↓ (OpenFeign)
GET /api/products/{id}
↓ (Product Service)
Retorna ProductDTO

Si falla:
→ Circuit Breaker abre
→ Fallback method activado
→ Retorna error de resiliencia
```

### 3. Flujo de Crear Pedido

```
1. Cliente: POST /api/orders con items
   ↓
2. Gateway enruta a Order Service
   ↓
3. Order Service:
   a) Para cada item:
      - GET ProductDTO (via OpenFeign)
      - Valida stock disponible
      - POST reserve stock
   
   b) Crea Order en BD
   
   c) Crea OrderItems en BD
   
   d) Retorna OrderDTO

Si falla en (a):
   → Circuit Breaker abre
   → Fallback lanza ProductServiceException
   → Transacción se revierte
```

## Base de Datos

### Producto (product_db)

```sql
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock INTEGER NOT NULL,
    sku VARCHAR(100) UNIQUE
);
```

### Orden (order_db)

```sql
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    total_price DECIMAL(10, 2) NOT NULL,
    status VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(id),
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL
);
```

## Stack Tecnológico

### Backend
- **Java 21**: Lenguaje de programación
- **Spring Boot 3.2+**: Framework web
- **Spring Cloud Gateway**: API Gateway y enrutamiento
- **Spring Cloud OpenFeign**: Cliente HTTP declarativo
- **Spring Data JPA**: ORM y acceso a datos
- **Resilience4j**: Circuit Breaker y resiliencia
- **SpringDoc OpenAPI**: Documentación Swagger
- **Jakarta Validation**: Validación de datos
- **PostgreSQL**: Base de datos relacional

### Frontend
- **React 18**: Librería de UI
- **React Router**: Enrutamiento del cliente
- **Axios**: Cliente HTTP
- **React Bootstrap**: Componentes UI
- **CSS3**: Estilos

### DevOps
- **Docker**: Containerización
- **Docker Compose**: Orquestación local
- **Gradle**: Build tool

## Características de Resiliencia

### 1. Circuit Breaker Pattern

```yaml
resilience4j:
  circuitbreaker:
    instances:
      productService:
        slidingWindowSize: 10      # Examina últimas 10 llamadas
        failureRateThreshold: 50   # 50% de fallos = abre
        waitDurationInOpenState: 10000  # 10s antes de probar
        permittedNumberOfCallsInHalfOpenState: 3  # 3 intentos
```

Estados:
- **CLOSED**: Funcionando normalmente
- **OPEN**: Bloqueando llamadas (producto caído)
- **HALF_OPEN**: Probando si está recuperado

### 2. Fallback Methods

Order Service implementa fallback:

```java
@CircuitBreaker(name = "productService", 
                fallbackMethod = "createOrderFallback")
public OrderDTO createOrder(OrderDTO orderDTO)

public OrderDTO createOrderFallback(OrderDTO orderDTO, Exception ex)
    → Lanza ProductServiceException
    → Cliente recibe error 503 Service Unavailable
```

### 3. Timeout y Retry (Configurable)

```yaml
resilience4j:
  timelimit:
    instances:
      productService:
        timeoutDuration: 2000ms
```

## Escalabilidad

### Pasos para agregar nuevos servicios

1. Crear módulo nuevo en `settings.gradle.kts`
2. Implementar controller, service, entity
3. Configurar `application.yml`
4. Crear Dockerfile
5. Agregar en docker-compose.yml
6. Registrar ruta en API Gateway

### Mejoras futuras

- **Eureka Service Discovery**: Eliminar hardcoded URLs
- **Load Balancer**: Múltiples instancias de cada servicio
- **Message Queue (Kafka)**: Comunicación asíncrona
- **Redis Cache**: Caché distribuida
- **API Versioning**: /api/v1/, /api/v2/
- **Authentication (JWT)**: Seguridad

## Monitoreo y Logging

Cada servicio loguea a:
- `org.springframework`: INFO
- `org.example.*`: DEBUG

Ver logs:
```bash
docker logs product-service
docker logs order-service
docker logs api-gateway
```

## Deployment

### Entorno Local
```bash
docker-compose up --build
```

### Entorno Producción
- Usar Kubernetes (minikube, EKS, GKE)
- Configurar Ingress para entrada única
- Usar ConfigMaps para configuración
- Secrets para credenciales BD
- PersistentVolumes para datos

