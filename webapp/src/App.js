import React, { useState } from 'react';
import ProductList from './components/ProductList';
import Cart from './components/Cart';
import Checkout from './components/Checkout';

export default function App() {
  const [cart, setCart] = useState([]);

  const handleAddToCart = (product) => {
    setCart(prev => {
      const found = prev.find(item => item.id === product.id);
      if (found) {
        return prev.map(item => item.id === product.id ? { ...item, quantity: item.quantity + 1 } : item);
      }
      return [...prev, { ...product, quantity: 1 }];
    });
  };

  const handleRemove = (id) => {
    setCart(prev => prev.filter(item => item.id !== id));
  };

  const handleOrderConfirmed = () => {
    setCart([]);
  };

  return (
    <div style={{
      minHeight: '100vh',
      backgroundColor: '#f5f5f5',
      fontFamily: 'Arial, sans-serif'
    }}>
      <header style={{
        backgroundColor: '#4CAF50',
        color: 'white',
        padding: '20px 40px',
        boxShadow: '0 2px 4px rgba(0,0,0,0.1)'
      }}>
        <h1 style={{ margin: 0 }}>🛒 E-Commerce Platform</h1>
        <p style={{ margin: '5px 0 0 0', opacity: 0.9 }}>
          Microservices Architecture Demo
        </p>
      </header>

      <div style={{
        display: 'grid',
        gridTemplateColumns: '2fr 1fr',
        gap: 20,
        padding: 20,
        maxWidth: 1400,
        margin: '0 auto'
      }}>
        <div>
          <ProductList onAddToCart={handleAddToCart} />
        </div>
        <div style={{ position: 'sticky', top: 20, height: 'fit-content' }}>
          <Cart cart={cart} onRemove={handleRemove} />
          <Checkout cart={cart} onOrderConfirmed={handleOrderConfirmed} />
        </div>
      </div>
    </div>
  );
}

