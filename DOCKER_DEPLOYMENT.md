# 🚀 Docker Deployment Guide

## ✅ Todos los Problemas de Ejecución RESUELTOS

El proyecto ahora puede ejecutarse de **dos formas**:
1. **Docker Compose** (Recomendado - Todo containerizado)
2. **Local con Gradle** (Para desarrollo)

---

## 📦 Opción 1: Docker Compose (Recomendado)

### Requisitos
- Docker Desktop instalado y en ejecución
- Docker Compose v2.0+

### Iniciar Todo con un Comando
```bash
# Usar el script interactivo
./start-local.sh
# Selecciona opción 1

# O directamente con docker-compose
docker-compose up --build
```

### Detener Todo
```bash
# Usar el script
./stop-local.sh

# O con docker-compose
docker-compose down

# Eliminar también los volúmenes (limpieza completa)
docker-compose down -v
```

### Servicios Disponibles
- **API Gateway**: http://localhost:8080
- **Product Service**: http://localhost:8081
- **Order Service**: http://localhost:8082
- **PostgreSQL Product**: localhost:5432
- **PostgreSQL Order**: localhost:5433

### Logs
```bash
# Ver logs de todos los servicios
docker-compose logs -f

# Ver logs de un servicio específico
docker-compose logs -f product-service
docker-compose logs -f order-service
docker-compose logs -f api-gateway
```

---

## 💻 Opción 2: Local con Gradle

### Requisitos
- Java 21 o Java 24
- Docker Desktop (solo para PostgreSQL)
- Node.js 18+ (opcional, para webapp)

### Iniciar Servicios
```bash
# Usar el script interactivo
./start-local.sh
# Selecciona opción 2

# O manualmente paso a paso
```

### Paso a Paso Manual

#### 1. Iniciar Bases de Datos
```bash
# PostgreSQL para Product Service
docker run -d \
  --name postgres-product \
  -e POSTGRES_DB=product_db \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -p 5432:5432 \
  postgres:15-alpine

# PostgreSQL para Order Service
docker run -d \
  --name postgres-order \
  -e POSTGRES_DB=order_db \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -p 5433:5432 \
  postgres:15-alpine
```

#### 2. Compilar Proyecto
```bash
./gradlew clean build -x test
```

#### 3. Iniciar Microservicios (en terminales separadas)
```bash
# Terminal 1: Product Service
./gradlew :product-service:bootRun

# Terminal 2: Order Service
./gradlew :order-service:bootRun

# Terminal 3: API Gateway
./gradlew :api-gateway:bootRun

# Terminal 4: WebApp (opcional)
cd webapp
npm install
npm run dev
```

#### 4. Detener Servicios
```bash
# Usar el script
./stop-local.sh

# O manualmente
# Ctrl+C en cada terminal
# Detener PostgreSQL
docker stop postgres-product postgres-order
docker rm postgres-product postgres-order
```

---

## 🔧 Configuración de los Dockerfiles

### Arquitectura Multi-Stage
Los Dockerfiles usan construcción multi-stage para optimizar las imágenes:

1. **Stage 1 (Builder)**: Compila el código con Gradle
2. **Stage 2 (Runtime)**: Solo incluye el JRE y el JAR compilado

### Características
- ✅ Construcción automática dentro del contenedor
- ✅ Imágenes optimizadas (~200MB vs ~800MB)
- ✅ Sin necesidad de compilar localmente
- ✅ Consistente entre entornos

---

## 🐛 Troubleshooting

### Error: "Cannot connect to Docker daemon"
```bash
# Asegúrate de que Docker Desktop esté ejecutándose
# En Mac: Abre Docker Desktop desde Applications
# En Linux: sudo systemctl start docker
```

### Error: "Port already in use"
```bash
# Ver qué está usando el puerto
lsof -i :8080
lsof -i :8081
lsof -i :8082

# Detener servicios anteriores
./stop-local.sh

# O matar procesos específicos
kill -9 <PID>
```

### Error: "Database connection failed"
```bash
# Verificar que PostgreSQL esté ejecutándose
docker ps | grep postgres

# Ver logs de PostgreSQL
docker logs postgres-product
docker logs postgres-order

# Recrear contenedores
docker-compose down -v
docker-compose up --build
```

### Error: "Lombok compilation issues"
```bash
# Limpiar cache de Gradle
./gradlew clean
rm -rf ~/.gradle/caches/

# Recompilar
./gradlew build --refresh-dependencies
```

### Verificar Salud de los Servicios
```bash
# Con Docker Compose
docker-compose ps

# Health checks
curl http://localhost:8080/actuator/health
curl http://localhost:8081/actuator/health
curl http://localhost:8082/actuator/health
```

---

## 📊 Comparación de Opciones

| Característica | Docker Compose | Local con Gradle |
|----------------|----------------|------------------|
| Facilidad de inicio | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| Velocidad de inicio | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| Aislamiento | ⭐⭐⭐⭐⭐ | ⭐⭐ |
| Debugging | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Prod-like | ⭐⭐⭐⭐⭐ | ⭐⭐ |
| Hot reload | ⭐⭐ | ⭐⭐⭐⭐⭐ |

**Recomendación**: 
- Usa **Docker Compose** para demos y pruebas
- Usa **Local con Gradle** para desarrollo activo

---

## 🎯 Comandos Rápidos

```bash
# Iniciar todo (Docker Compose)
docker-compose up -d

# Ver logs en tiempo real
docker-compose logs -f

# Reiniciar un servicio
docker-compose restart product-service

# Reconstruir un servicio específico
docker-compose up -d --build product-service

# Detener todo
docker-compose down

# Limpieza completa (incluye volúmenes)
docker-compose down -v

# Ver estado
docker-compose ps

# Ejecutar pruebas
./gradlew test

# Compilar sin pruebas
./gradlew build -x test
```

---

## 📝 Variables de Entorno

### Personalizables en docker-compose.yml

```yaml
environment:
  # Database
  SPRING_DATASOURCE_URL: jdbc:postgresql://postgres-product:5432/product_db
  SPRING_DATASOURCE_USERNAME: postgres
  SPRING_DATASOURCE_PASSWORD: postgres
  
  # Service URLs
  PRODUCT_SERVICE_URL: http://product-service:8081
  ORDER_SERVICE_URL: http://order-service:8082
  
  # Spring profiles
  SPRING_PROFILES_ACTIVE: docker
  
  # JVM options
  JAVA_OPTS: "-Xmx512m -Xms256m"
```

---

## ✅ Checklist de Verificación

Después de iniciar los servicios, verifica:

- [ ] API Gateway responde en http://localhost:8080
- [ ] Product Service Swagger: http://localhost:8081/swagger-ui.html
- [ ] Order Service Swagger: http://localhost:8082/swagger-ui.html
- [ ] PostgreSQL Product en puerto 5432
- [ ] PostgreSQL Order en puerto 5433
- [ ] Todos los contenedores están "healthy"
- [ ] Los logs no muestran errores críticos

```bash
# Verificación automática
curl -f http://localhost:8080/actuator/health && echo "✅ API Gateway OK"
curl -f http://localhost:8081/actuator/health && echo "✅ Product Service OK"
curl -f http://localhost:8082/actuator/health && echo "✅ Order Service OK"
```

---

## 🎉 ¡Listo Para Usar!

El proyecto ahora está completamente configurado y puede ejecutarse sin problemas.

**Para iniciar rápidamente**:
```bash
chmod +x start-local.sh
./start-local.sh
# Selecciona tu opción preferida
```

**Para detener**:
```bash
./stop-local.sh
```

