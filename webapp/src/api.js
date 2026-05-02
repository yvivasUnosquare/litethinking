import axios from 'axios';

const api = axios.create({
  baseURL: '/api', // El gateway debe estar en la misma URL base o configurar proxy
  headers: {
    'Content-Type': 'application/json',
  },
});

// Interceptores para manejo global de errores
api.interceptors.response.use(
  response => response,
  error => {
    // Puedes personalizar el manejo de errores aquí
    return Promise.reject(error);
  }
);

export default api;

