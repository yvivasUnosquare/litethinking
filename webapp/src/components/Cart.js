import React from 'react';

export default function Cart({ cart, onRemove }) {
  const total = cart.reduce((sum, item) => sum + item.price * item.quantity, 0);

  return (
    <div style={{ padding: 20, border: '1px solid #ddd', borderRadius: 8, minWidth: 300 }}>
      <h2>Shopping Cart</h2>
      {cart.length === 0 ? (
        <div style={{ color: '#999', padding: 20, textAlign: 'center' }}>
          Cart is empty
        </div>
      ) : (
        <div>
          <ul style={{ listStyle: 'none', padding: 0 }}>
            {cart.map(item => (
              <li
                key={item.id}
                style={{
                  marginBottom: 15,
                  padding: 10,
                  border: '1px solid #eee',
                  borderRadius: 4,
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center'
                }}
              >
                <div>
                  <div style={{ fontWeight: 'bold' }}>{item.name}</div>
                  <div style={{ fontSize: 14, color: '#666' }}>
                    ${item.price.toFixed(2)} × {item.quantity}
                  </div>
                  <div style={{ fontSize: 16, color: '#4CAF50', fontWeight: 'bold' }}>
                    ${(item.price * item.quantity).toFixed(2)}
                  </div>
                </div>
                <button
                  onClick={() => onRemove(item.id)}
                  style={{
                    padding: '5px 10px',
                    backgroundColor: '#f44336',
                    color: 'white',
                    border: 'none',
                    borderRadius: 4,
                    cursor: 'pointer'
                  }}
                >
                  Remove
                </button>
              </li>
            ))}
          </ul>
          <div style={{
            marginTop: 15,
            paddingTop: 15,
            borderTop: '2px solid #4CAF50',
            fontSize: 20,
            fontWeight: 'bold'
          }}>
            Total: ${total.toFixed(2)}
          </div>
        </div>
      )}
    </div>
  );
}

