# 🛒 E-Commerce WebApp - User Guide

## Overview

Modern React-based e-commerce web application that integrates with a microservices backend.

## ✨ Features

### Product Catalog
- Browse all available products
- View detailed product information:
  - Name and description
  - Category
  - Current price
  - Stock availability
- Add products to shopping cart
- Out-of-stock products are clearly marked and disabled

### Shopping Cart
- View all items in your cart
- See quantity and unit price for each item
- View subtotal for each item
- Total price calculation
- Remove items from cart
- Empty cart indicator

### Checkout
- Enter customer information:
  - Full name (required)
  - Email address (required, validated)
- Form validation with helpful error messages
- Order confirmation with order details
- Success/error feedback

### Stock Management
- Real-time stock availability
- Stock updated after each order
- Prevents ordering out-of-stock items

## 🚀 Getting Started

### Prerequisites
- Node.js 18+ installed
- Backend services running (Product Service, Order Service, API Gateway)

### Installation

1. Navigate to webapp directory:
```bash
cd webapp
```

2. Install dependencies:
```bash
npm install
```

3. Start development server:
```bash
npm run dev
```

4. Open your browser:
```
http://localhost:5173
```

## 📋 How to Use

### Step 1: Browse Products
- The home page displays all available products in a grid layout
- Each product card shows:
  - Product name and description
  - Category badge
  - Price
  - Stock availability
  - "Add to Cart" button

### Step 2: Add Items to Cart
1. Click "Add to Cart" on any product
2. The item appears in your cart (right sidebar)
3. Quantity increases if you add the same product again
4. View running total at bottom of cart

### Step 3: Manage Your Cart
- Review items in your cart
- Check quantities and prices
- Remove items you don't want
- See your total before checkout

### Step 4: Complete Checkout
1. Enter your full name in the "Customer Name" field
2. Enter your email in the "Customer Email" field
3. Click "Confirm Order" button
4. Wait for confirmation message

### Step 5: Order Confirmation
- Success message displays your order ID and total
- Your cart is automatically cleared
- Stock is updated for ordered items

## 🎨 UI Components

### Product Card
```
┌─────────────────────────┐
│  Product Name           │
│  Description here...    │
│  [Category Badge]       │
│                         │
│  $999.99                │
│  Stock: 50 available    │
│                         │
│  [  Add to Cart  ]      │
└─────────────────────────┘
```

### Cart Item
```
┌─────────────────────────┐
│  Product Name           │
│  $100.00 × 2            │
│  $200.00                │
│           [Remove]      │
└─────────────────────────┘
```

### Checkout Form
```
┌─────────────────────────┐
│  Checkout               │
│  ─────────────────────  │
│  Customer Name:         │
│  [________________]     │
│                         │
│  Customer Email:        │
│  [________________]     │
│                         │
│  [ Confirm Order ]      │
└─────────────────────────┘
```

## ⚠️ Validation Rules

### Customer Name
- Cannot be empty
- Whitespace is trimmed
- Error: "Please enter your name and email"

### Customer Email
- Cannot be empty
- Must contain '@' symbol
- Whitespace is trimmed
- Error: "Please enter a valid email address"

### Cart Requirements
- Must have at least one item to checkout
- "Confirm Order" button disabled when cart is empty

## 🔧 Configuration

### API Proxy
The app uses Vite's proxy feature to connect to the backend:

```javascript
// vite.config.js
proxy: {
  '/api': {
    target: 'http://localhost:8080',  // API Gateway
    changeOrigin: true
  }
}
```

All API calls go through the gateway at `localhost:8080`.

### Backend URLs
- **API Gateway**: http://localhost:8080
- **Product Service**: http://localhost:8081
- **Order Service**: http://localhost:8082

## 🐛 Troubleshooting

### Issue: "Cannot GET /api/products"

**Solution:** Make sure the backend services are running:
```bash
./gradlew :product-service:bootRun
./gradlew :order-service:bootRun
./gradlew :api-gateway:bootRun
```

### Issue: "Order failed"

**Causes:**
1. Missing customer name or email
2. Empty cart
3. Invalid product ID
4. Insufficient stock
5. Backend service down

**Solution:**
- Fill in all required fields
- Check browser console for detailed errors
- Verify backend services are running

### Issue: Cart not updating

**Solution:**
- Refresh the page
- Check browser console for errors
- Verify Product Service is responding

### Issue: Node version error

**Current Setup:**
- Node.js 18.20.3 ✅
- Vite 4.5.3 (compatible with Node 18+)

If you see version warnings, it's safe to ignore them as long as the app runs.

## 📊 API Endpoints Used

| Endpoint | Method | Purpose | Request Body |
|----------|--------|---------|--------------|
| `/api/products` | GET | List products | - |
| `/api/products/{id}` | GET | Get product | - |
| `/api/orders` | POST | Create order | `{customerName, customerEmail, items}` |
| `/api/orders` | GET | List orders | - |

## 💡 Tips

1. **Multiple Items**: Click "Add to Cart" multiple times to increase quantity
2. **Stock Check**: Look at stock count before ordering large quantities
3. **Email Format**: Must include '@' symbol for validation to pass
4. **Cart Total**: Updates automatically as you add/remove items
5. **Success Message**: Shows your order ID for reference

## 🎯 Sample Workflow

### Creating Your First Order

1. Start the webapp:
   ```bash
   cd webapp && npm run dev
   ```

2. View products in the catalog

3. Click "Add to Cart" on an iPhone (or any product)

4. Click it again to add 2 items

5. Review your cart on the right side

6. In the checkout form, enter:
   - Name: John Doe
   - Email: john@example.com

7. Click "Confirm Order"

8. See success message:
   ```
   Order #1 confirmed! Total: $2400.00
   ```

9. Your cart is now empty and ready for next order

## 🔍 Debug Mode

To see detailed logs in browser console:
1. Open browser DevTools (F12)
2. Go to Console tab
3. You'll see:
   - API requests
   - Responses
   - Errors (if any)

## 📱 Responsive Design

The UI adapts to different screen sizes:
- **Desktop**: Two-column layout (products left, cart right)
- **Tablet**: Stacked layout with full-width cards
- **Mobile**: Single column, touch-friendly buttons

## 🔐 Data Privacy

- Customer information is sent securely to the backend
- No data is stored in browser localStorage
- Email validation prevents malformed addresses
- All communication via localhost (development)

## 📈 Performance

- Fast initial load with Vite
- Hot module replacement (changes appear instantly)
- Optimized React rendering
- Minimal API calls
- Efficient state management

## 🆘 Support

If you encounter issues:

1. Check backend services are running
2. Check browser console for errors
3. Review logs:
   ```bash
   tail -f /tmp/product-service.log
   tail -f /tmp/order-service.log
   tail -f /tmp/api-gateway.log
   ```
4. Restart services if needed
5. Clear browser cache

## 📚 Related Documentation

- `UI_FIX.md` - Technical implementation details
- `UI_INTEGRATION_SUCCESS.md` - Integration test results
- `API_GATEWAY_FIX.md` - Gateway configuration
- `HOW_TO_RUN.md` - Complete setup guide

## ✅ Checklist

Before using the app, ensure:
- [ ] PostgreSQL containers running
- [ ] Product Service started (port 8081)
- [ ] Order Service started (port 8082)
- [ ] API Gateway started (port 8080)
- [ ] Node modules installed (`npm install`)
- [ ] Development server running (`npm run dev`)
- [ ] Browser opened to http://localhost:5173

## 🎉 Enjoy Shopping!

Your e-commerce platform is ready to use. Start browsing products and creating orders!

**Happy Shopping! 🛒**

