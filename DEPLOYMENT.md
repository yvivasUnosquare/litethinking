# Deployment Checklist

## Pre-Deployment

### Code Review
- [ ] Todos los tests pasan
- [ ] No hay warnings de linting
- [ ] Documentación actualizada
- [ ] Código revisado por equipo
- [ ] No hay secrets en el código

### Testing
- [ ] Pruebas unitarias: `./gradlew test`
- [ ] Pruebas manuales completadas
- [ ] Casos edge testeados
- [ ] Performance testeado
- [ ] Seguridad validada

### Configuración
- [ ] Variables de entorno configuradas
- [ ] Base de datos preparada
- [ ] URLs correctas en configuración
- [ ] Logs configurados apropiadamente
- [ ] Rate limiting configurado

### Seguridad
- [ ] Contraseñas BD cambiadas
- [ ] API keys generadas
- [ ] CORS configurado
- [ ] HTTPS habilitado
- [ ] Secrets guardados en vault

## Build

### Java Microservices
```bash
# Build multi-módulo
./gradlew clean build

# Verificar JAR creados
ls -la product-service/build/libs/
ls -la order-service/build/libs/
ls -la api-gateway/build/libs/
```

### Frontend
```bash
cd frontend
npm ci  # Install locked versions
npm run build
# Verificar carpeta build/ creada
```

### Docker Images
```bash
# Build imágenes
docker-compose build

# Verificar imágenes
docker images | grep ecommerce

# Test localmente
docker-compose up --build
```

## Deployment Local

### 1. Iniciar infraestructura
```bash
docker-compose up -d postgres-product postgres-order
```

### 2. Esperar a que BD estén listas
```bash
# Verificar
docker-compose ps
docker logs postgres-product
docker logs postgres-order
```

### 3. Iniciar servicios
```bash
# Opción A: Docker Compose
docker-compose up -d

# Opción B: Gradle local
./gradlew :product-service:bootRun &
./gradlew :order-service:bootRun &
./gradlew :api-gateway:bootRun &
cd frontend && npm start &
```

## Health Checks

### Verificar Servicios Activos

**Product Service**
```bash
curl -i http://localhost:8081/product-service/actuator/health
# Esperado: HTTP 200 { "status": "UP" }
```

**Order Service**
```bash
curl -i http://localhost:8082/order-service/actuator/health
# Esperado: HTTP 200 { "status": "UP" }
```

**API Gateway**
```bash
curl -i http://localhost:8080/actuator/health
# Esperado: HTTP 200 { "status": "UP" }
```

**Frontend**
```bash
curl -i http://localhost:3000
# Esperado: HTTP 200 (HTML)
```

### Verificar Conectividad BD

**PostgreSQL Product**
```bash
docker exec postgres-product psql -U postgres -d product_db -c "SELECT 1"
# Esperado: 1
```

**PostgreSQL Order**
```bash
docker exec postgres-order psql -U postgres -d order_db -c "SELECT 1"
# Esperado: 1
```

### API Tests

**Crear Producto**
```bash
curl -X POST http://localhost:8080/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Product",
    "description": "Test",
    "price": 99.99,
    "stock": 10,
    "sku": "TEST-001"
  }'
# Esperado: HTTP 201 + ProductDTO
```

**Listar Productos**
```bash
curl http://localhost:8080/api/products
# Esperado: HTTP 200 + Array de productos
```

**Crear Orden**
```bash
curl -X POST http://localhost:8080/api/orders \
  -H "Content-Type: application/json" \
  -d '{
    "items": [
      {
        "productId": 1,
        "quantity": 2,
        "unitPrice": 99.99
      }
    ],
    "totalPrice": 199.98
  }'
# Esperado: HTTP 201 + OrderDTO
```

## Post-Deployment

### Monitoring

**Logs**
```bash
# Seguir logs en tiempo real
docker-compose logs -f

# Logs específicos
docker-compose logs -f product-service
docker-compose logs -f order-service
docker-compose logs -f api-gateway
```

**Performance**
```bash
# CPU y memoria
docker stats

# Información detallada
docker inspect <container-id>
```

**Database**
```bash
# Conectarse a BD
docker exec -it postgres-product psql -U postgres -d product_db

# Queries útiles
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM orders;
```

### Backups

**Base de Datos**
```bash
# Backup product_db
docker exec postgres-product pg_dump -U postgres product_db > product_db_backup.sql

# Backup order_db
docker exec postgres-order pg_dump -U postgres order_db > order_db_backup.sql
```

## Rollback Plan

### Si algo falla

**Opción 1: Recrear contenedores**
```bash
docker-compose down
docker-compose up --build
```

**Opción 2: Rollback de datos**
```bash
# Restaurar backup
docker exec -i postgres-product psql -U postgres product_db < product_db_backup.sql
docker exec -i postgres-order psql -U postgres order_db < order_db_backup.sql
```

**Opción 3: Limpieza completa**
```bash
./cleanup.sh
# Reconstruir desde cero
./start-local.sh
```

## Kubernetes Deployment (Futuro)

### Preparación
- [ ] Kubernetes cluster disponible
- [ ] kubectl configurado
- [ ] Docker registry (DockerHub, ECR, etc)
- [ ] Helm charts creados
- [ ] ConfigMaps para configuración
- [ ] Secrets para credenciales

### Pasos
```bash
# Construir imágenes para registry
docker tag product-service:1.0 registry.example.com/product-service:1.0
docker push registry.example.com/product-service:1.0

# Similar para otros servicios...

# Deployar con Helm
helm install ecommerce ./helm/ecommerce-chart
```

## Performance Optimization

### Recomendaciones Post-Deployment

1. **Database**
   - [ ] Crear índices en columnas buscadas
   - [ ] Vacuum y analyze periódicamente
   - [ ] Backups automáticos
   - [ ] Replicación configurada

2. **Cache**
   - [ ] Implementar Redis
   - [ ] Cache de productos
   - [ ] Session store distribuido

3. **API**
   - [ ] Rate limiting
   - [ ] Compression (gzip)
   - [ ] CDN para assets estáticos

4. **Aplicación**
   - [ ] JVM tuning (heap size)
   - [ ] Connection pooling optimizado
   - [ ] Monitoring y alertas

## Continuous Integration

### GitHub Actions / Jenkins

```yaml
name: Deploy
on: [push]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-java@v2
        with:
          java-version: 21
      - run: ./gradlew test
      
  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - run: docker-compose build
      - run: docker-compose push
      
  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - run: kubectl apply -f k8s/
```

## Sign-Off

- [ ] **QA Lead**: Validó funcionamiento
- [ ] **DevOps**: Validó infraestructura
- [ ] **Security**: Validó seguridad
- [ ] **Project Manager**: Aprobó release
- [ ] **Customer**: Aceptó deployment

---

**Deployment realizado por:** _________________ **Fecha:** _________________

**Versión:** 1.0.0
**Ambiente:** [ ] Dev [ ] Staging [ ] Production

