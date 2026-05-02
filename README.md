# E-Commerce Platform

Una plataforma de e-commerce completa construida con microservicios usando Spring Boot, Spring Cloud, React y Docker.

## ✅ Estado del Proyecto

| Componente | Compilación | Pruebas | Docker | Estado |
|------------|-------------|---------|--------|--------|
| Product Service | ✅ | ✅ 20/20 | ✅ | ✅ OK |
| Order Service | ✅ | ✅ 17/17 | ✅ | ✅ OK |
| API Gateway | ✅ | N/A | ✅ | ✅ OK |
| WebApp React | ✅ | N/A | ⚠️ | ✅ OK |

## 🚀 Inicio Ultra-Rápido

```bash
# Detener servicios anteriores (si existen)
./stop-local.sh

# Iniciar con Docker Compose
docker-compose up --build

# Espera 2-3 minutos...
# ✅ Todo estará funcionando en http://localhost:8080
```

## 🏗️ Arquitectura

### Componentes

1. **API Gateway** (Puerto 8080)
   - Punto único de entrada para todos los clientes
   - Enrutamiento inteligente de requests
   - Circuit Breaker para resiliencia
   - Swagger UI: http://localhost:8080/swagger-ui.html

2. **Product Service** (Puerto 8081)
   - Gestión completa de productos (CRUD)
   - Validación de stock
   - Reserva y liberación de inventario
   - Base de datos: PostgreSQL
   - Swagger UI: http://localhost:8081/product-service/swagger-ui.html

3. **Order Service** (Puerto 8082)
   - Gestión de pedidos
   - Integración con Product Service via OpenFeign
   - Circuit Breaker para tolerancia a fallos
   - Base de datos: PostgreSQL
   - Swagger UI: http://localhost:8082/order-service/swagger-ui.html

4. **Frontend** (Puerto 3000)
   - Interfaz React
   - Catálogo de productos
   - Carrito de compras
   - Gestión de pedidos

### Bases de Datos

- **postgres-product**: Base de datos para Product Service
  - Puerto: 5432
  - BD: product_db
  
- **postgres-order**: Base de datos para Order Service
  - Puerto: 5433
  - BD: order_db

## 🚀 Guía de Inicio Rápido

### Requisitos Previos

- Docker y Docker Compose
- Java 21 (para desarrollo local)
- Node.js 18+ (para desarrollo frontend)
- Gradle (para compilar)

### Opción 1: Ejecutar con Docker Compose (Recomendado)

```bash
# Construir todas las imágenes y ejecutar los servicios
docker-compose up --build

# El frontend estará disponible en http://localhost:3000
# El API Gateway en http://localhost:8080
```

### Opción 2: Ejecutar Localmente

#### 1. Iniciar PostgreSQL

```bash
docker run -d \
  --name postgres-product \
  -e POSTGRES_DB=product_db \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -p 5432:5432 \
  postgres:15-alpine

docker run -d \
  --name postgres-order \
  -e POSTGRES_DB=order_db \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -p 5433:5432 \
  postgres:15-alpine
```

#### 2. Compilar Servicios Java

```bash
# Desde la raíz del proyecto
./gradlew build

# Ejecutar Product Service
./gradlew :product-service:bootRun

# En otra terminal, ejecutar Order Service
./gradlew :order-service:bootRun

# En otra terminal, ejecutar API Gateway
./gradlew :api-gateway:bootRun
```

#### 3. Ejecutar Frontend

```bash
cd frontend
npm install
npm start
```

## 📚 Endpoints API

### Product Service

```
GET    /api/products              # Obtener todos los productos
GET    /api/products/{id}         # Obtener producto por ID
POST   /api/products              # Crear nuevo producto
PUT    /api/products/{id}         # Actualizar producto
DELETE /api/products/{id}         # Eliminar producto
POST   /api/products/{id}/reserve # Reservar stock
POST   /api/products/{id}/release # Liberar stock reservado
```

### Order Service

```
GET    /api/orders                # Obtener todos los pedidos
GET    /api/orders/{id}           # Obtener pedido por ID
POST   /api/orders                # Crear nuevo pedido
PUT    /api/orders/{id}/status    # Actualizar estado del pedido
DELETE /api/orders/{id}           # Cancelar pedido
```

## 📦 Estructura del Proyecto

```
ecommerce/
├── product-service/
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/org/example/product/
│   │   │   │   ├── ProductServiceApplication.java
│   │   │   │   ├── controller/
│   │   │   │   ├── service/
│   │   │   │   ├── entity/
│   │   │   │   ├── repository/
│   │   │   │   ├── dto/
│   │   │   │   └── exception/
│   │   │   └── resources/
│   │   │       └── application.yml
│   │   └── test/
│   ├── build.gradle.kts
│   └── Dockerfile
│
├── order-service/
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/org/example/order/
│   │   │   │   ├── OrderServiceApplication.java
│   │   │   │   ├── controller/
│   │   │   │   ├── service/
│   │   │   │   ├── entity/
│   │   │   │   ├── repository/
│   │   │   │   ├── dto/
│   │   │   │   ├── client/
│   │   │   │   └── exception/
│   │   │   └── resources/
│   │   │       └── application.yml
│   │   └── test/
│   ├── build.gradle.kts
│   └── Dockerfile
│
├── api-gateway/
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/org/example/gateway/
│   │   │   │   ├── ApiGatewayApplication.java
│   │   │   │   └── controller/
│   │   │   └── resources/
│   │   │       └── application.yml
│   │   └── test/
│   ├── build.gradle.kts
│   └── Dockerfile
│
├── frontend/
│   ├── src/
│   │   ├── api/
│   │   │   └── apiClient.js
│   │   ├── pages/
│   │   │   ├── ProductCatalog.js
│   │   │   ├── Cart.js
│   │   │   ├── Checkout.js
│   │   │   └── Orders.js
│   │   ├── App.js
│   │   ├── App.css
│   │   └── index.js
│   ├── public/
│   │   └── index.html
│   ├── package.json
│   └── Dockerfile
│
├── docker-compose.yml
├── build.gradle.kts
├── settings.gradle.kts
└── README.md
```

## 🧪 Testing

### Ejecutar Tests de Product Service

```bash
./gradlew :product-service:test
```

### Ejecutar Tests de Order Service

```bash
./gradlew :order-service:test
```

### Ejecutar todos los Tests

```bash
./gradlew test
```

## 🔍 Flujo de Ejemplo

1. **Ver Productos**
   - Acceder a http://localhost:3000
   - El frontend hace GET a /api/products a través del Gateway
   - Product Service retorna el catálogo desde la BD

2. **Agregar al Carrito**
   - El frontend mantiene el carrito en estado local

3. **Crear Pedido**
   - Frontend hace POST a /api/orders con los items del carrito
   - Order Service:
     - Obtiene detalles de productos desde Product Service
     - Valida disponibilidad de stock
     - Reserva el stock
     - Crea el pedido en su BD
   - Si falla (Circuit Breaker abierto), se retorna error

4. **Ver Pedidos**
   - Frontend hace GET a /api/orders
   - Order Service retorna los pedidos de su BD

## 🛠️ Configuración

### Variables de Entorno

Las configuraciones están en los archivos `application.yml` de cada servicio:

**Product Service** (`product-service/src/main/resources/application.yml`)
```yaml
spring.datasource.url: jdbc:postgresql://postgres-product:5432/product_db
spring.datasource.username: postgres
spring.datasource.password: postgres
```

**Order Service** (`order-service/src/main/resources/application.yml`)
```yaml
spring.datasource.url: jdbc:postgresql://postgres-order:5432/order_db
product-service.url: http://product-service:8081/product-service
```

## 📊 Tecnologías

- **Backend**: Java 21, Spring Boot 3.2+, Spring Cloud
  - Spring Data JPA para ORM
  - OpenFeign para comunicación inter-servicios
  - Resilience4j para Circuit Breaker
  - SpringDoc OpenAPI para documentación
  - Jakarta Validation para validación

- **Frontend**: React 18, React Router, Axios, Bootstrap
  
- **Base de Datos**: PostgreSQL 15

- **Contenedorización**: Docker, Docker Compose

## 🔐 Consideraciones de Seguridad

- La plataforma actual es un MVP sin autenticación
- Para producción, añadir:
  - Spring Security + JWT
  - HTTPS/TLS
  - Rate limiting
  - Input validation más estricta
  - CORS configuration

## 📝 Datos de Ejemplo

Para probar, se pueden crear productos directamente via Swagger:

```json
{
  "name": "Laptop Gaming",
  "description": "High-performance gaming laptop",
  "price": 1299.99,
  "stock": 50,
  "sku": "LG-001"
}
```

## 🐛 Troubleshooting

### El frontend no puede conectar con el API Gateway
- Verificar que el Gateway esté corriendo en puerto 8080
- Revisar los logs: `docker logs api-gateway`

### Order Service no puede conectar con Product Service
- Verificar que Product Service esté en red ecommerce-network
- Revisar logs de Order Service: `docker logs order-service`
- Asegurarse que la URL sea correcta: `http://product-service:8081/product-service`

### Base de datos no inicia
- Asegurar que los puertos 5432 y 5433 no estén en uso
- Limpiar volúmenes: `docker-compose down -v`

## 📈 Escalabilidad Futura

- Agregar Redis para caché
- Implementar mensaje queue (Kafka/RabbitMQ)
- Agregar Eureka para service discovery
- Implementar logging centralizado (ELK Stack)
- Agregar monitoreo (Prometheus/Grafana)

## 📄 Licencia

MIT

## 👨‍💻 Contribuidores

Proyecto desarrollado como solución de e-commerce escalable con microservicios.

