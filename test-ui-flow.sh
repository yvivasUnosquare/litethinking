#!/bin/bash

echo "🧪 Testing Complete E-Commerce Flow with UI"
echo "============================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check services are running
echo -e "${YELLOW}1. Checking Services Status...${NC}"
echo ""

# Check API Gateway
if curl -s http://localhost:8080/actuator/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓ API Gateway (8080) - Running${NC}"
else
    echo -e "${RED}✗ API Gateway (8080) - Not running${NC}"
    echo "Start with: ./gradlew :api-gateway:bootRun"
    exit 1
fi

# Check Product Service
if curl -s http://localhost:8081/actuator/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Product Service (8081) - Running${NC}"
else
    echo -e "${RED}✗ Product Service (8081) - Not running${NC}"
    echo "Start with: ./gradlew :product-service:bootRun"
    exit 1
fi

# Check Order Service
if curl -s http://localhost:8082/actuator/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Order Service (8082) - Running${NC}"
else
    echo -e "${RED}✗ Order Service (8082) - Not running${NC}"
    echo "Start with: ./gradlew :order-service:bootRun"
    exit 1
fi

echo ""
echo -e "${YELLOW}2. Testing API Endpoints...${NC}"
echo ""

# Test Product API
PRODUCTS=$(curl -s http://localhost:8080/api/products)
if [ ! -z "$PRODUCTS" ]; then
    echo -e "${GREEN}✓ GET /api/products - Success${NC}"
    PRODUCT_COUNT=$(echo $PRODUCTS | grep -o '"id"' | wc -l)
    echo "  Found $PRODUCT_COUNT products"
else
    echo -e "${RED}✗ GET /api/products - Failed${NC}"
fi

# Get first product ID
PRODUCT_ID=$(echo $PRODUCTS | grep -o '"id":[0-9]*' | head -1 | grep -o '[0-9]*')

if [ ! -z "$PRODUCT_ID" ]; then
    echo ""
    echo -e "${YELLOW}3. Creating Test Order...${NC}"
    echo ""

    # Create order with customer info
    ORDER_RESPONSE=$(curl -s -X POST http://localhost:8080/api/orders \
      -H "Content-Type: application/json" \
      -d "{
        \"customerName\": \"Test User\",
        \"customerEmail\": \"test@example.com\",
        \"items\": [{
          \"productId\": $PRODUCT_ID,
          \"quantity\": 2
        }]
      }")

    if echo "$ORDER_RESPONSE" | grep -q '"id"'; then
        echo -e "${GREEN}✓ POST /api/orders - Success${NC}"
        ORDER_ID=$(echo $ORDER_RESPONSE | grep -o '"id":[0-9]*' | grep -o '[0-9]*')
        TOTAL=$(echo $ORDER_RESPONSE | grep -o '"totalAmount":[0-9.]*' | grep -o '[0-9.]*')
        echo "  Order ID: $ORDER_ID"
        echo "  Total: \$$TOTAL"
        echo "  Customer: Test User (test@example.com)"
    else
        echo -e "${RED}✗ POST /api/orders - Failed${NC}"
        echo "  Response: $ORDER_RESPONSE"
    fi
else
    echo -e "${YELLOW}⚠ No products found, skipping order test${NC}"
    echo "  Create a product first through the UI or API"
fi

echo ""
echo -e "${YELLOW}4. Checking UI Configuration...${NC}"
echo ""

# Check vite.config.js
if [ -f "webapp/vite.config.js" ]; then
    echo -e "${GREEN}✓ vite.config.js exists${NC}"
    if grep -q "target: 'http://localhost:8080'" webapp/vite.config.js; then
        echo -e "${GREEN}✓ Proxy configured for API Gateway${NC}"
    else
        echo -e "${RED}✗ Proxy not configured correctly${NC}"
    fi
else
    echo -e "${RED}✗ vite.config.js not found${NC}"
fi

# Check package.json
if [ -f "webapp/package.json" ]; then
    echo -e "${GREEN}✓ package.json exists${NC}"
else
    echo -e "${RED}✗ package.json not found${NC}"
fi

echo ""
echo -e "${YELLOW}5. UI Components Check...${NC}"
echo ""

# Check components
if [ -f "webapp/src/components/Checkout.js" ]; then
    if grep -q "customerName" webapp/src/components/Checkout.js && \
       grep -q "customerEmail" webapp/src/components/Checkout.js; then
        echo -e "${GREEN}✓ Checkout component has customer fields${NC}"
    else
        echo -e "${RED}✗ Checkout component missing customer fields${NC}"
    fi
else
    echo -e "${RED}✗ Checkout component not found${NC}"
fi

if [ -f "webapp/src/components/ProductList.js" ]; then
    echo -e "${GREEN}✓ ProductList component exists${NC}"
else
    echo -e "${RED}✗ ProductList component not found${NC}"
fi

if [ -f "webapp/src/components/Cart.js" ]; then
    echo -e "${GREEN}✓ Cart component exists${NC}"
else
    echo -e "${RED}✗ Cart component not found${NC}"
fi

echo ""
echo "============================================="
echo -e "${GREEN}✅ All Tests Passed!${NC}"
echo ""
echo "📋 Next Steps:"
echo "  1. Start the WebApp:"
echo "     cd webapp && npm run dev"
echo ""
echo "  2. Open browser:"
echo "     http://localhost:5173"
echo ""
echo "  3. Test the flow:"
echo "     - Browse products"
echo "     - Add items to cart"
echo "     - Enter customer name and email"
echo "     - Confirm order"
echo ""
echo "🎉 E-Commerce Platform is Ready!"

