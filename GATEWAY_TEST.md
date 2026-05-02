# 🧪 API Gateway Testing Guide

## Quick Test Commands

### Test Products Endpoint
```bash
# List all products
curl http://localhost:8080/api/products

# Get specific product
curl http://localhost:8080/api/products/1

# Create new product
curl -X POST http://localhost:8080/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "MacBook Pro",
    "description": "M3 Max",
    "category": "Computers",
    "price": 2999.99,
    "stock": 50
  }'

# Update product
curl -X PUT http://localhost:8080/api/products/1 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "iPhone 15 Pro",
    "description": "Latest model",
    "category": "Electronics",
    "price": 1299.99,
    "stock": 150
  }'

# Delete product
curl -X DELETE http://localhost:8080/api/products/1
```

### Test Orders Endpoint
```bash
# List all orders
curl http://localhost:8080/api/orders

# Get specific order
curl http://localhost:8080/api/orders/1

# Create new order
curl -X POST http://localhost:8080/api/orders \
  -H "Content-Type: application/json" \
  -d '{
    "customerName": "John Doe",
    "customerEmail": "john@example.com",
    "items": [
      {
        "productId": 1,
        "quantity": 2
      }
    ]
  }'

# Get orders by customer email
curl http://localhost:8080/api/orders?customerEmail=john@example.com
```

### Test Circuit Breaker / Fallback
```bash
# Access fallback endpoint directly
curl http://localhost:8080/api/fallback/products
curl http://localhost:8080/api/fallback/orders

# To test circuit breaker:
# 1. Stop Product Service: Ctrl+C in terminal
# 2. Try accessing products through gateway
curl http://localhost:8080/api/products
# Should return fallback response with 503 status
```

### Test Direct Service Access (Comparison)
```bash
# Direct Product Service
curl http://localhost:8081/api/products

# Through Gateway
curl http://localhost:8080/api/products

# Both should return the same data
```

## Expected Responses

### Successful Product List
```json
[
  {
    "id": 1,
    "name": "iPhone",
    "description": "17 Max",
    "category": "Electronics",
    "price": 1200.00,
    "stock": 100,
    "createdAt": "2026-05-01T19:51:59.586357",
    "updatedAt": "2026-05-01T19:51:59.586377"
  }
]
```

### Successful Order Creation
```json
{
  "id": 1,
  "customerName": "John Doe",
  "customerEmail": "john@example.com",
  "totalAmount": 2400.00,
  "status": "CONFIRMED",
  "createdAt": "2026-05-01T20:00:00",
  "items": [
    {
      "productId": 1,
      "productName": "iPhone",
      "quantity": 2,
      "price": 1200.00
    }
  ]
}
```

### Fallback Response (Service Unavailable)
```json
{
  "status": 503,
  "error": "Product Service is temporarily unavailable. Please try again later."
}
```

### Error Response (Validation Failed)
```json
{
  "status": 400,
  "error": "Bad Request",
  "message": "Validation failed",
  "timestamp": "2026-05-01T20:00:00",
  "details": {
    "name": "must not be blank",
    "price": "must be greater than 0"
  }
}
```

## Performance Testing

### Basic Load Test (using curl in loop)
```bash
# Test gateway routing 100 times
for i in {1..100}; do
  curl -s http://localhost:8080/api/products > /dev/null
  echo "Request $i completed"
done
```

### With Apache Bench (if installed)
```bash
# 1000 requests, 10 concurrent
ab -n 1000 -c 10 http://localhost:8080/api/products
```

## Monitoring

### Check Gateway Health
```bash
curl http://localhost:8080/actuator/health
```

### View Gateway Routes
```bash
curl http://localhost:8080/actuator/gateway/routes | jq
```

### Circuit Breaker Metrics
```bash
curl http://localhost:8080/actuator/metrics/resilience4j.circuitbreaker.calls
```

## Swagger UI Testing

Open in browser:
- **Gateway**: http://localhost:8080/swagger-ui.html
- **Product Service**: http://localhost:8081/swagger-ui.html
- **Order Service**: http://localhost:8082/swagger-ui.html

## Troubleshooting

### Gateway not responding
```bash
# Check if gateway is running
lsof -i :8080

# Check logs
tail -f /tmp/gateway.log

# Restart gateway
./gradlew :api-gateway:bootRun
```

### 503 errors
```bash
# Check if backend services are running
curl http://localhost:8081/api/products  # Product Service
curl http://localhost:8082/api/orders    # Order Service

# If not, start them
./gradlew :product-service:bootRun
./gradlew :order-service:bootRun
```

### Wrong responses
```bash
# Clear cache and rebuild
./gradlew :api-gateway:clean :api-gateway:build -x test
./gradlew :api-gateway:bootRun
```

## Complete Test Script

Save as `test-all.sh`:
```bash
#!/bin/bash

echo "🧪 Testing Complete E-Commerce Platform via API Gateway"
echo "========================================================="

# Test 1: Create Product
echo -e "\n1️⃣ Creating product..."
PRODUCT_ID=$(curl -s -X POST http://localhost:8080/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Product",
    "description": "Testing",
    "category": "Test",
    "price": 99.99,
    "stock": 100
  }' | jq -r '.id')
echo "Created product with ID: $PRODUCT_ID"

# Test 2: List Products
echo -e "\n2️⃣ Listing products..."
curl -s http://localhost:8080/api/products | jq

# Test 3: Create Order
echo -e "\n3️⃣ Creating order..."
ORDER_ID=$(curl -s -X POST http://localhost:8080/api/orders \
  -H "Content-Type: application/json" \
  -d "{
    \"customerName\": \"Test User\",
    \"customerEmail\": \"test@example.com\",
    \"items\": [{
      \"productId\": $PRODUCT_ID,
      \"quantity\": 2
    }]
  }" | jq -r '.id')
echo "Created order with ID: $ORDER_ID"

# Test 4: Verify Order
echo -e "\n4️⃣ Verifying order..."
curl -s http://localhost:8080/api/orders/$ORDER_ID | jq

# Test 5: Check Stock
echo -e "\n5️⃣ Checking updated stock..."
curl -s http://localhost:8080/api/products/$PRODUCT_ID | jq '.stock'

echo -e "\n✅ All tests completed!"
```

Run with:
```bash
chmod +x test-all.sh
./test-all.sh
```

## Status

✅ **API Gateway is fully operational**
- Routing works correctly
- Circuit breaker configured
- Fallbacks implemented
- All endpoints accessible

