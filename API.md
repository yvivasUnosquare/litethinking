# API Documentation

## Base URL

```
Development:  http://localhost:8080
Production:   https://api.example.com
```

## Product Service API

### GET /api/products

Obtiene el listado completo de productos.

**Parámetros Query:**
- `page` (opcional): Número de página (default: 0)
- `size` (opcional): Cantidad de items por página (default: 20)
- `sort` (opcional): Campo para ordenar (default: id)

**Respuesta Exitosa (200 OK):**

```json
[
  {
    "id": 1,
    "name": "iPhone 15",
    "description": "Latest Apple smartphone",
    "price": 999.99,
    "stock": 50,
    "sku": "IPHONE-15-001"
  },
  {
    "id": 2,
    "name": "Samsung Galaxy S24",
    "description": "Premium Android phone",
    "price": 899.99,
    "stock": 30,
    "sku": "GALAXY-S24-001"
  }
]
```

**Respuesta Error (500 Internal Server Error):**

```json
{
  "timestamp": "2024-04-27T10:30:00",
  "status": 500,
  "message": "An unexpected error occurred"
}
```

---

### GET /api/products/{id}

Obtiene los detalles de un producto específico.

**Parámetros Path:**
- `id` (requerido): ID del producto

**Respuesta Exitosa (200 OK):**

```json
{
  "id": 1,
  "name": "iPhone 15",
  "description": "Latest Apple smartphone",
  "price": 999.99,
  "stock": 50,
  "sku": "IPHONE-15-001"
}
```

**Respuesta Error (404 Not Found):**

```json
{
  "timestamp": "2024-04-27T10:30:00",
  "status": 404,
  "message": "Product not found with id: 999"
}
```

---

### POST /api/products

Crea un nuevo producto.

**Headers:**
- `Content-Type: application/json`

**Body:**

```json
{
  "name": "iPhone 15",
  "description": "Latest Apple smartphone",
  "price": 999.99,
  "stock": 50,
  "sku": "IPHONE-15-001"
}
```

**Respuesta Exitosa (201 Created):**

```json
{
  "id": 1,
  "name": "iPhone 15",
  "description": "Latest Apple smartphone",
  "price": 999.99,
  "stock": 50,
  "sku": "IPHONE-15-001"
}
```

**Respuesta Error (400 Bad Request):**

```json
{
  "timestamp": "2024-04-27T10:30:00",
  "status": 400,
  "message": "Validation failed",
  "errors": {
    "name": "Product name is required",
    "price": "Price must be greater than 0"
  }
}
```

---

### PUT /api/products/{id}

Actualiza un producto existente.

**Parámetros Path:**
- `id` (requerido): ID del producto

**Body:**

```json
{
  "name": "iPhone 15 Updated",
  "description": "Updated description",
  "price": 1099.99,
  "stock": 60,
  "sku": "IPHONE-15-001"
}
```

**Respuesta Exitosa (200 OK):**

```json
{
  "id": 1,
  "name": "iPhone 15 Updated",
  "description": "Updated description",
  "price": 1099.99,
  "stock": 60,
  "sku": "IPHONE-15-001"
}
```

---

### DELETE /api/products/{id}

Elimina un producto.

**Parámetros Path:**
- `id` (requerido): ID del producto

**Respuesta Exitosa (204 No Content):**

```
(Sin body)
```

---

### POST /api/products/{id}/reserve

Reserva stock de un producto.

**Parámetros Path:**
- `id` (requerido): ID del producto

**Parámetros Query:**
- `quantity` (requerido): Cantidad a reservar

**Respuesta Exitosa (200 OK):**

```
(Sin body)
```

**Respuesta Error (400 Bad Request - Stock insuficiente):**

```json
{
  "timestamp": "2024-04-27T10:30:00",
  "status": 400,
  "message": "Insufficient stock for product: 1. Available: 5, Requested: 10"
}
```

---

### POST /api/products/{id}/release

Libera stock reservado de un producto.

**Parámetros Path:**
- `id` (requerido): ID del producto

**Parámetros Query:**
- `quantity` (requerido): Cantidad a liberar

**Respuesta Exitosa (200 OK):**

```
(Sin body)
```

---

## Order Service API

### GET /api/orders

Obtiene el listado completo de pedidos.

**Parámetros Query:**
- `page` (opcional): Número de página
- `size` (opcional): Cantidad de items por página

**Respuesta Exitosa (200 OK):**

```json
[
  {
    "id": 1,
    "totalPrice": 2899.97,
    "status": "PENDING",
    "createdAt": "2024-04-27T10:30:00",
    "items": [
      {
        "id": 1,
        "productId": 1,
        "quantity": 2,
        "unitPrice": 999.99
      },
      {
        "id": 2,
        "productId": 2,
        "quantity": 1,
        "unitPrice": 899.99
      }
    ]
  }
]
```

---

### GET /api/orders/{id}

Obtiene los detalles de un pedido específico.

**Parámetros Path:**
- `id` (requerido): ID del pedido

**Respuesta Exitosa (200 OK):**

```json
{
  "id": 1,
  "totalPrice": 2899.97,
  "status": "PENDING",
  "createdAt": "2024-04-27T10:30:00",
  "items": [
    {
      "id": 1,
      "productId": 1,
      "quantity": 2,
      "unitPrice": 999.99
    }
  ]
}
```

---

### POST /api/orders

Crea un nuevo pedido. **Nota:** Automáticamente reserva stock del Product Service.

**Headers:**
- `Content-Type: application/json`

**Body:**

```json
{
  "items": [
    {
      "productId": 1,
      "quantity": 2,
      "unitPrice": 999.99
    },
    {
      "productId": 2,
      "quantity": 1,
      "unitPrice": 899.99
    }
  ],
  "totalPrice": 2899.97
}
```

**Respuesta Exitosa (201 Created):**

```json
{
  "id": 1,
  "totalPrice": 2899.97,
  "status": "PENDING",
  "createdAt": "2024-04-27T10:30:00",
  "items": [
    {
      "id": 1,
      "productId": 1,
      "quantity": 2,
      "unitPrice": 999.99
    },
    {
      "id": 2,
      "productId": 2,
      "quantity": 1,
      "unitPrice": 899.99
    }
  ]
}
```

**Respuesta Error (503 Service Unavailable - Product Service caído):**

```json
{
  "timestamp": "2024-04-27T10:30:00",
  "status": 503,
  "message": "Product Service is temporarily unavailable. Please try again later."
}
```

---

### PUT /api/orders/{id}/status

Actualiza el estado de un pedido.

**Parámetros Path:**
- `id` (requerido): ID del pedido

**Parámetros Query:**
- `status` (requerido): Nuevo estado (PENDING, CONFIRMED, SHIPPED, DELIVERED, CANCELLED)

Ejemplo: `PUT /api/orders/1/status?status=CONFIRMED`

**Respuesta Exitosa (200 OK):**

```json
{
  "id": 1,
  "totalPrice": 2899.97,
  "status": "CONFIRMED",
  "createdAt": "2024-04-27T10:30:00",
  "items": [...]
}
```

---

### DELETE /api/orders/{id}

Cancela un pedido. **Nota:** Automáticamente libera stock reservado en Product Service.

**Parámetros Path:**
- `id` (requerido): ID del pedido

**Respuesta Exitosa (204 No Content):**

```
(Sin body)
```

---

## HTTP Status Codes

| Code | Descripción |
|------|-------------|
| 200 | OK - Solicitud exitosa |
| 201 | Created - Recurso creado |
| 204 | No Content - Solicitud exitosa sin body |
| 400 | Bad Request - Validación fallida |
| 404 | Not Found - Recurso no encontrado |
| 500 | Internal Server Error - Error del servidor |
| 503 | Service Unavailable - Servicio no disponible |

## Códigos de Estado de Pedido

| Status | Descripción |
|--------|-------------|
| PENDING | Pedido pendiente de confirmación |
| CONFIRMED | Pedido confirmado |
| SHIPPED | Pedido enviado |
| DELIVERED | Pedido entregado |
| CANCELLED | Pedido cancelado |

## Error Handling

Todos los errores siguen el mismo formato:

```json
{
  "timestamp": "ISO 8601 datetime",
  "status": "HTTP status code",
  "message": "Descripción del error",
  "errors": {} // Opcional: detalles de validación
}
```

## Rate Limiting

Actualmente sin límite. En producción implementar:

```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1234567890
```

## CORS

Headers configurados:

```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization
```

## Versionado de API

Plan futuro: `/api/v1/products`, `/api/v2/products`

## Documentación Interactiva

Swagger UI disponible en:

- Product Service: `http://localhost:8081/product-service/swagger-ui.html`
- Order Service: `http://localhost:8082/order-service/swagger-ui.html`
- API Gateway: `http://localhost:8080/swagger-ui.html`

OpenAPI JSON:

- Product Service: `http://localhost:8081/product-service/v3/api-docs`
- Order Service: `http://localhost:8082/order-service/v3/api-docs`

