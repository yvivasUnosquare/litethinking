import React, { useEffect, useState } from 'react';
import api from '../api';

export default function ProductList({ onAddToCart }) {
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    api.get('/products')
      .then(res => setProducts(res.data))
      .catch(err => setError(err.response?.data?.error || 'Error loading products'))
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <div style={{ padding: 20 }}>Loading products...</div>;
  if (error) return <div style={{color:'red', padding: 20}}>{error}</div>;

  return (
    <div style={{ padding: 20 }}>
      <h1>Product Catalog</h1>
      {products.length === 0 ? (
        <div style={{ color: '#999' }}>No products available</div>
      ) : (
        <div style={{ display: 'grid', gap: 20, gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))' }}>
          {products.map(product => (
            <div
              key={product.id}
              style={{
                border: '1px solid #ddd',
                borderRadius: 8,
                padding: 20,
                backgroundColor: '#fff',
                boxShadow: '0 2px 4px rgba(0,0,0,0.1)'
              }}
            >
              <h3 style={{ margin: '0 0 10px 0', color: '#333' }}>{product.name}</h3>
              <div style={{ fontSize: 14, color: '#666', marginBottom: 8 }}>
                {product.description}
              </div>
              <div style={{
                display: 'inline-block',
                padding: '4px 8px',
                backgroundColor: '#e3f2fd',
                borderRadius: 4,
                fontSize: 12,
                marginBottom: 8,
                color: '#1976d2'
              }}>
                {product.category}
              </div>
              <div style={{ fontSize: 24, fontWeight: 'bold', color: '#4CAF50', margin: '10px 0' }}>
                ${product.price.toFixed(2)}
              </div>
              <div style={{ fontSize: 14, color: product.stock > 0 ? '#666' : '#f44336', marginBottom: 10 }}>
                Stock: {product.stock > 0 ? `${product.stock} available` : 'Out of stock'}
              </div>
              <button
                onClick={() => onAddToCart(product)}
                disabled={product.stock === 0}
                style={{
                  width: '100%',
                  padding: '10px 20px',
                  backgroundColor: product.stock === 0 ? '#ccc' : '#4CAF50',
                  color: 'white',
                  border: 'none',
                  borderRadius: 4,
                  cursor: product.stock === 0 ? 'not-allowed' : 'pointer',
                  fontSize: 16,
                  fontWeight: 'bold'
                }}
              >
                {product.stock === 0 ? 'Out of Stock' : 'Add to Cart'}
              </button>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

