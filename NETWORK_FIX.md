# 🔥 SOLUCIÓN AL ERROR: UnknownHostException: postgres-product

## ❌ El Problema

```
Caused by: java.net.UnknownHostException: postgres-product
```

Este error ocurre cuando los servicios Spring Boot no pueden resolver el nombre del host `postgres-product` porque **no están en la misma red Docker**.

## ✅ Solución Aplicada

He actualizado `docker-compose.yml` para agregar los servicios PostgreSQL a la red `ecommerce-network`:

```yaml
postgres-product:
  # ...
  networks:
    - ecommerce-network  # ✅ AGREGADO

postgres-order:
  # ...
  networks:
    - ecommerce-network  # ✅ AGREGADO
```

## 🚀 Cómo Ejecutar Correctamente

### Paso 1: Detener Servicios Anteriores

```bash
# Detener y limpiar todo
./stop-local.sh

# O manualmente
docker-compose down -v
docker stop postgres-product postgres-order 2>/dev/null
docker rm postgres-product postgres-order 2>/dev/null
```

### Paso 2: Iniciar con Docker Compose

```bash
# IMPORTANTE: Usa docker-compose para que todos estén en la misma red
docker-compose up --build

# NO uses estos comandos manualmente:
# ❌ docker run ... postgres-product
# ❌ ./gradlew :product-service:bootRun
```

### Paso 3: Verificar que Funciona

```bash
# Espera 2-3 minutos y luego verifica
curl http://localhost:8080/actuator/health
curl http://localhost:8081/actuator/health
curl http://localhost:8082/actuator/health

# Todos deberían responder: {"status":"UP"}
```

## 🔍 Verificar la Red Docker

```bash
# Ver la red creada
docker network ls | grep ecommerce

# Ver qué contenedores están en la red
docker network inspect ecommerce_ecommerce-network

# Deberías ver:
# - postgres-product
# - postgres-order
# - product-service
# - order-service
# - api-gateway
```

## 🐛 Si Aún Tienes Problemas

### 1. Limpieza Completa

```bash
# Detener todo
docker-compose down -v

# Limpiar redes Docker
docker network prune -f

# Limpiar contenedores y volúmenes
docker system prune -a --volumes -f

# Reiniciar Docker Desktop
# Mac: Quit y abrir de nuevo
# Linux: sudo systemctl restart docker
```

### 2. Verificar docker-compose.yml

Asegúrate de que TODOS los servicios tengan:

```yaml
networks:
  - ecommerce-network
```

### 3. Verificar Logs

```bash
# Ver logs de todos los servicios
docker-compose logs -f

# Ver logs específicos
docker-compose logs product-service | grep -i "postgres\|error"
docker-compose logs order-service | grep -i "postgres\|error"
```

## 📋 Checklist de Verificación

- [ ] Ejecutaste `docker-compose down -v`
- [ ] No hay contenedores PostgreSQL corriendo fuera de docker-compose
- [ ] Todos los servicios en docker-compose.yml tienen `networks: - ecommerce-network`
- [ ] Ejecutaste `docker-compose up --build` (NO comandos individuales)
- [ ] Esperaste al menos 2-3 minutos para que todo inicie
- [ ] Los health checks responden correctamente

## ✅ Comandos Correctos

```bash
# ✅ CORRECTO - Usa docker-compose
docker-compose up --build
docker-compose down
docker-compose logs -f

# ❌ INCORRECTO - No mezcles con comandos manuales
docker run -d postgres...  # ❌ NO
./gradlew :product-service:bootRun  # ❌ NO (solo para desarrollo local)
```

## 🎯 Resultado Esperado

Después de ejecutar `docker-compose up --build`, deberías ver:

```bash
# docker-compose ps

NAME                STATUS              PORTS
postgres-product    Up (healthy)        0.0.0.0:5432->5432/tcp
postgres-order      Up (healthy)        0.0.0.0:5433->5432/tcp
product-service     Up                  0.0.0.0:8081->8081/tcp
order-service       Up                  0.0.0.0:8082->8082/tcp
api-gateway         Up                  0.0.0.0:8080->8080/tcp
```

Y los logs mostrarán:

```
✅ Started ProductServiceApplication
✅ Started OrderServiceApplication
✅ Started ApiGatewayApplication
```

## 📚 Más Información

- [DOCKER_DEPLOYMENT.md](DOCKER_DEPLOYMENT.md) - Guía completa
- [RUN_FIX_SUMMARY.md](RUN_FIX_SUMMARY.md) - Todas las soluciones aplicadas

## 🆘 ¿Aún No Funciona?

Si después de seguir todos estos pasos aún tienes problemas:

1. **Reinicia Docker Desktop completamente**
2. **Verifica que tienes Docker Compose v2.0+**: `docker-compose version`
3. **Verifica espacio en disco**: `df -h`
4. **Verifica memoria disponible**: Mínimo 4GB recomendado

```bash
# Reinicio completo
docker-compose down -v
docker system prune -a --volumes -f
# Reinicia Docker Desktop
docker-compose up --build
```

---

**¿Funcionó? ¡Excelente! 🎉**

Ahora puedes acceder a:
- API Gateway: http://localhost:8080
- Product Service: http://localhost:8081/swagger-ui.html
- Order Service: http://localhost:8082/swagger-ui.html

