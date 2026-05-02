import React, { useState } from 'react';
import api from '../api';

export default function Checkout({ cart, onOrderConfirmed }) {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(null);
  const [customerName, setCustomerName] = useState('');
  const [customerEmail, setCustomerEmail] = useState('');

  const handleCheckout = () => {
    if (!customerName.trim() || !customerEmail.trim()) {
      setError('Please enter your name and email');
      return;
    }

    if (!customerEmail.includes('@')) {
      setError('Please enter a valid email address');
      return;
    }

    setLoading(true);
    setError(null);
    setSuccess(null);
    const order = {
      customerName: customerName.trim(),
      customerEmail: customerEmail.trim(),
      items: cart.map(item => ({ productId: item.id, quantity: item.quantity })),
    };
    api.post('/orders', order)
      .then(res => {
        setSuccess(`Order #${res.data.id} confirmed! Total: $${res.data.totalAmount}`);
        setCustomerName('');
        setCustomerEmail('');
        onOrderConfirmed();
      })
      .catch(err => setError(err.response?.data?.message || err.response?.data?.error || 'Order failed'))
      .finally(() => setLoading(false));
  };

  return (
    <div style={{ marginTop: 20, padding: 20, border: '1px solid #ddd', borderRadius: 8 }}>
      <h2>Checkout</h2>
      <div style={{ marginBottom: 10 }}>
        <label style={{ display: 'block', marginBottom: 5 }}>
          Customer Name:
          <input
            type="text"
            value={customerName}
            onChange={(e) => setCustomerName(e.target.value)}
            placeholder="Enter your name"
            style={{
              width: '100%',
              padding: 8,
              marginTop: 5,
              border: '1px solid #ccc',
              borderRadius: 4
            }}
            disabled={loading}
          />
        </label>
      </div>
      <div style={{ marginBottom: 15 }}>
        <label style={{ display: 'block', marginBottom: 5 }}>
          Customer Email:
          <input
            type="email"
            value={customerEmail}
            onChange={(e) => setCustomerEmail(e.target.value)}
            placeholder="Enter your email"
            style={{
              width: '100%',
              padding: 8,
              marginTop: 5,
              border: '1px solid #ccc',
              borderRadius: 4
            }}
            disabled={loading}
          />
        </label>
      </div>
      <button
        onClick={handleCheckout}
        disabled={loading || cart.length === 0}
        style={{
          padding: '10px 20px',
          backgroundColor: cart.length === 0 ? '#ccc' : '#4CAF50',
          color: 'white',
          border: 'none',
          borderRadius: 4,
          cursor: cart.length === 0 ? 'not-allowed' : 'pointer',
          fontSize: 16,
          fontWeight: 'bold'
        }}
      >
        {loading ? 'Processing...' : 'Confirm Order'}
      </button>
      {error && <div style={{color:'red', marginTop: 10, padding: 10, backgroundColor: '#ffe6e6', borderRadius: 4}}>{error}</div>}
      {success && <div style={{color:'green', marginTop: 10, padding: 10, backgroundColor: '#e6ffe6', borderRadius: 4}}>{success}</div>}
    </div>
  );
}

