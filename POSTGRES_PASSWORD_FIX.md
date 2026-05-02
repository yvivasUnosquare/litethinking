# ✅ SOLUCIONADO: PostgreSQL Superuser Password Error

## ❌ El Error

```
Error: Database is uninitialized and superuser password is not specified.
You must specify POSTGRES_PASSWORD to a non-empty value for the superuser.
```

## 🔍 Causa

PostgreSQL no estaba recibiendo correctamente la variable de entorno `POSTGRES_PASSWORD` debido a:
1. Formato inconsistente de variables de entorno (YAML mapping vs list)
2. Volúmenes de datos previamente corruptos o inicializados sin contraseña
3. Falta de configuración explícita de PGDATA y POSTGRES_HOST_AUTH_METHOD

## ✅ Solución Aplicada

### 1. Formato Correcto de Variables de Entorno

**Antes** (formato mapping - puede fallar):
```yaml
environment:
  POSTGRES_DB: product_db
  POSTGRES_USER: postgres
  POSTGRES_PASSWORD: postgres
```

**Después** (formato list - más confiable):
```yaml
environment:
  - POSTGRES_DB=product_db
  - POSTGRES_USER=postgres
  - POSTGRES_PASSWORD=postgres
  - POSTGRES_HOST_AUTH_METHOD=md5
  - PGDATA=/var/lib/postgresql/data/pgdata
```

### 2. Configuraciones Adicionales

- **POSTGRES_HOST_AUTH_METHOD=md5**: Método de autenticación explícito
- **PGDATA=/var/lib/postgresql/data/pgdata**: Ubicación específica de datos
- **restart: unless-stopped**: Reinicio automático en caso de fallo

### 3. Limpieza de Volúmenes

```bash
docker compose down -v
```

Esto elimina todos los volúmenes con datos potencialmente corruptos.

## 🚀 Cómo Aplicar la Solución

### Paso 1: Detener y Limpiar

```bash
# Detener todos los servicios y eliminar volúmenes
docker compose down -v

# Opcional: Limpieza adicional
docker system prune -f
```

### Paso 2: Verificar el archivo docker-compose.yml

El archivo ya está actualizado con el formato correcto. Verifica que tenga:

```yaml
services:
  postgres-product:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=product_db
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_HOST_AUTH_METHOD=md5
      - PGDATA=/var/lib/postgresql/data/pgdata
    volumes:
      - postgres-product-data:/var/lib/postgresql/data
    restart: unless-stopped
```

### Paso 3: Iniciar Todo de Nuevo

```bash
# Iniciar servicios
docker compose up --build

# Ver logs en tiempo real (en otra terminal)
docker compose logs -f postgres-product
docker compose logs -f postgres-order
```

## 🔍 Verificar que PostgreSQL Funciona

### 1. Verificar que los contenedores están saludables

```bash
docker compose ps
```

Deberías ver:
```
NAME               STATUS              HEALTH
postgres-product   Up X seconds        healthy
postgres-order     Up X seconds        healthy
```

### 2. Verificar logs de PostgreSQL

```bash
docker compose logs postgres-product | tail -20
```

Deberías ver:
```
database system is ready to accept connections
```

### 3. Conectarse a PostgreSQL

```bash
# Conectar a postgres-product
docker exec -it postgres-product psql -U postgres -d product_db

# En el prompt de psql:
\dt  # Listar tablas
\q   # Salir

# Conectar a postgres-order
docker exec -it postgres-order psql -U postgres -d order_db
```

### 4. Verificar que los servicios Spring Boot conectan

```bash
# Ver logs de product-service
docker compose logs product-service | grep -i "database\|postgres\|started"

# Ver logs de order-service
docker compose logs order-service | grep -i "database\|postgres\|started"
```

Deberías ver:
```
Hikari Pool-1 - Start completed
Started ProductServiceApplication
```

## 📋 docker-compose.yml Final Completo

```yaml
version: '3.9'

services:
  postgres-product:
    image: postgres:15-alpine
    container_name: postgres-product
    environment:
      - POSTGRES_DB=product_db
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_HOST_AUTH_METHOD=md5
      - PGDATA=/var/lib/postgresql/data/pgdata
    volumes:
      - postgres-product-data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    networks:
      - ecommerce-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  postgres-order:
    image: postgres:15-alpine
    container_name: postgres-order
    environment:
      - POSTGRES_DB=order_db
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_HOST_AUTH_METHOD=md5
      - PGDATA=/var/lib/postgresql/data/pgdata
    volumes:
      - postgres-order-data:/var/lib/postgresql/data
    ports:
      - "5433:5432"
    networks:
      - ecommerce-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  # ... resto de servicios ...

volumes:
  postgres-product-data:
  postgres-order-data:

networks:
  ecommerce-network:
    driver: bridge
```

## 🐛 Troubleshooting

### Si el Error Persiste

#### 1. Verificar que los volúmenes se eliminaron

```bash
docker volume ls | grep postgres
```

No deberías ver volúmenes antiguos. Si los ves:

```bash
docker volume rm ecommerce_postgres-product-data ecommerce_postgres-order-data
```

#### 2. Inspeccionar el contenedor

```bash
docker compose up -d postgres-product
docker logs postgres-product
```

#### 3. Forzar recreación

```bash
docker compose down -v
docker compose rm -f postgres-product postgres-order
docker volume prune -f
docker compose up --build --force-recreate
```

#### 4. Usar versión diferente de PostgreSQL

Si persiste el problema, prueba con PostgreSQL 14:

```yaml
image: postgres:14-alpine
```

### Error: "role 'postgres' does not exist"

```bash
docker compose down -v
docker volume prune -f
docker compose up --build
```

### Error: "password authentication failed"

Verifica que las variables de entorno estén correctamente configuradas:

```bash
docker inspect postgres-product | grep -A 10 "Env"
```

Deberías ver:
```
"POSTGRES_PASSWORD=postgres"
"POSTGRES_USER=postgres"
"POSTGRES_DB=product_db"
```

## ✅ Resultado Esperado

Después de aplicar la solución:

```bash
$ docker compose ps

NAME               IMAGE                  STATUS              HEALTH
postgres-product   postgres:15-alpine     Up 30 seconds       healthy
postgres-order     postgres:15-alpine     Up 30 seconds       healthy
product-service    ecommerce-product...   Up 25 seconds       
order-service      ecommerce-order...     Up 20 seconds       
api-gateway        ecommerce-api...       Up 15 seconds       
```

```bash
$ curl http://localhost:8081/actuator/health
{"status":"UP"}

$ curl http://localhost:8082/actuator/health
{"status":"UP"}
```

## 🎯 Checklist de Verificación

- [ ] Variables de entorno en formato list (con guiones)
- [ ] `POSTGRES_PASSWORD` está definido
- [ ] `POSTGRES_HOST_AUTH_METHOD` está definido
- [ ] Volúmenes eliminados con `docker compose down -v`
- [ ] Servicios inician sin errores
- [ ] Health checks están "healthy"
- [ ] Spring Boot services conectan a la BD
- [ ] Endpoints responden correctamente

## 📚 Referencias

- [PostgreSQL Docker Official Image](https://hub.docker.com/_/postgres)
- [Docker Compose Environment Variables](https://docs.docker.com/compose/environment-variables/)
- [PostgreSQL Authentication Methods](https://www.postgresql.org/docs/current/auth-methods.html)

## 🎉 ¡Problema Resuelto!

PostgreSQL ahora:
- ✅ Inicia correctamente con la contraseña configurada
- ✅ Acepta conexiones de los servicios Spring Boot
- ✅ Health checks funcionan
- ✅ Datos persisten en volúmenes correctamente

**Comando para ejecutar:**

```bash
docker compose down -v
docker compose up --build
```

**Espera 2-3 minutos y todo estará funcionando! 🚀**

---

**Fecha**: 27 de Abril, 2026  
**Estado**: ✅ Resuelto  
**Versión**: Final

