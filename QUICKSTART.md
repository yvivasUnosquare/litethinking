# Quick Start Guide - Guía Rápida

## ⚡ 5 Minutos para Empezar

### Requisito Mínimo: Docker
```bash
# 1. Clonar el repositorio
git clone <repository-url>
cd ecommerce

# 2. Iniciar con Docker Compose
docker-compose up --build

# 3. Acceder
Frontend:  http://localhost:3000
Gateway:   http://localhost:8080
```

**¡Listo!** 🎉

---

## 📋 Opciones de Inicio

### Opción 1: Docker Compose (Más Fácil)
```bash
docker-compose up --build
# Esperar ~30s para que todo inicie
# Acceder a http://localhost:3000
```

### Opción 2: Gradle + Docker BD
```bash
# Terminal 1: Databases
docker-compose up postgres-product postgres-order

# Terminal 2: Product Service
./gradlew :product-service:bootRun

# Terminal 3: Order Service
./gradlew :order-service:bootRun

# Terminal 4: API Gateway
./gradlew :api-gateway:bootRun

# Terminal 5: Frontend
cd frontend && npm install && npm start
```

### Opción 3: Usar Script Proporcionado
```bash
chmod +x start-local.sh
./start-local.sh
```

---

## 🧪 Probar la Plataforma

### 1. Crear un Producto
```bash
curl -X POST http://localhost:8080/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "iPhone 15",
    "description": "Latest smartphone",
    "price": 999.99,
    "stock": 100,
    "sku": "IPHONE-15"
  }'
```

### 2. Ver Productos
```bash
curl http://localhost:8080/api/products
```

### 3. Crear Orden
```bash
curl -X POST http://localhost:8080/api/orders \
  -H "Content-Type: application/json" \
  -d '{
    "items": [
      {
        "productId": 1,
        "quantity": 2,
        "unitPrice": 999.99
      }
    ],
    "totalPrice": 1999.98
  }'
```

### 4. Ver Órdenes
```bash
curl http://localhost:8080/api/orders
```

---

## 🔗 URLs Importantes

| Servicio | URL |
|----------|-----|
| **Frontend** | http://localhost:3000 |
| **API Gateway** | http://localhost:8080 |
| **Product Service** | http://localhost:8081/product-service |
| **Order Service** | http://localhost:8082/order-service |
| **Product Swagger** | http://localhost:8081/product-service/swagger-ui.html |
| **Order Swagger** | http://localhost:8082/order-service/swagger-ui.html |

---

## 📚 Documentación Completa

- **README.md** - Visión general y arquitectura
- **ARCHITECTURE.md** - Diagramas y patrones
- **API.md** - Documentación de endpoints
- **DEVELOPMENT.md** - Guía de desarrollo
- **TESTING.md** - Ejemplos de testing
- **DEPLOYMENT.md** - Checklist de deployment
- **SUMMARY.md** - Resumen ejecutivo

---

## 🛑 Parar Servicios

```bash
# Detener Docker Compose
docker-compose down

# Detener específico
docker-compose down product-service

# Limpiar datos
docker-compose down -v
```

---

## ❓ Troubleshooting

### Puerto en uso
```bash
lsof -i :8080  # Ver qué usa el puerto
kill -9 <PID>  # Matar proceso
```

### BD no responde
```bash
docker-compose logs postgres-product
docker restart postgres-product
```

### Frontend no conecta
```bash
# Verificar Gateway esté corriendo
curl http://localhost:8080

# Ver console del navegador (F12)
```

### Build falla
```bash
./gradlew clean build --refresh-dependencies
```

---

## ✅ Verificar que Todo Funciona

```bash
# 1. Verificar servicios levantados
docker-compose ps

# 2. Probar Gateway
curl http://localhost:8080

# 3. Probar BD
docker exec postgres-product psql -U postgres -d product_db -c "SELECT 1"

# 4. Ver logs
docker-compose logs -f

# 5. Abrir navegador
# http://localhost:3000
```

---

## 🚀 Próximos Pasos

1. **Explorar la UI**: http://localhost:3000
2. **Leer README.md**: Para entender la arquitectura
3. **Ver Swagger**: Para probar APIs directamente
4. **Revisar DEVELOPMENT.md**: Para contribuir código

---

## 📞 Ayuda Rápida

| Pregunta | Respuesta |
|----------|-----------|
| ¿Cómo inicio todo? | `docker-compose up --build` |
| ¿Dónde testeo APIs? | http://localhost:8081/product-service/swagger-ui.html |
| ¿Cómo creo un producto? | POST a http://localhost:8080/api/products |
| ¿Cómo creo una orden? | POST a http://localhost:8080/api/orders |
| ¿Dónde veo la documentación? | README.md y Swagger |
| ¿Cómo ejecuto tests? | `./gradlew test` |
| ¿Cómo me conecto a la BD? | Ver DEVELOPMENT.md |

---

**Versión:** 1.0.0 | **Última actualización:** Abril 27, 2024

