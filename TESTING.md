# Scripts para Testing y Desarrollo

## Crear productos de ejemplo

```bash
curl -X POST http://localhost:8080/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "iPhone 15",
    "description": "Latest Apple smartphone",
    "price": 999.99,
    "stock": 100,
    "sku": "IPHONE-15-001"
  }'

curl -X POST http://localhost:8080/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Samsung Galaxy S24",
    "description": "Premium Android phone",
    "price": 899.99,
    "stock": 80,
    "sku": "GALAXY-S24-001"
  }'

curl -X POST http://localhost:8080/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "MacBook Pro",
    "description": "Professional laptop",
    "price": 2499.99,
    "stock": 30,
    "sku": "MACBOOK-PRO-001"
  }'
```

## Obtener todos los productos

```bash
curl http://localhost:8080/api/products
```

## Obtener producto por ID

```bash
curl http://localhost:8080/api/products/1
```

## Crear pedido

```bash
curl -X POST http://localhost:8080/api/orders \
  -H "Content-Type: application/json" \
  -d '{
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
  }'
```

## Obtener todos los pedidos

```bash
curl http://localhost:8080/api/orders
```

## Obtener pedido por ID

```bash
curl http://localhost:8080/api/orders/1
```

## Actualizar estado del pedido

```bash
curl -X PUT "http://localhost:8080/api/orders/1/status?status=CONFIRMED" \
  -H "Content-Type: application/json"
```

## Cancelar pedido

```bash
curl -X DELETE http://localhost:8080/api/orders/1
```

