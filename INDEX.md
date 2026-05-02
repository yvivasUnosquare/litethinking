# 📚 Documentación E-commerce Platform

Bienvenido a la documentación completa de la plataforma E-commerce basada en microservicios.

## 🚀 Inicio Rápido

**¿Tienes prisa?** → [QUICKSTART.md](./QUICKSTART.md) - 5 minutos para empezar

```bash
docker-compose up --build
# Acceder a http://localhost:3000
```

## 📖 Documentación Completa

### 📋 Estructura Principal

| Documento | Contenido | Lectura |
|-----------|-----------|---------|
| **[README.md](./README.md)** | Visión general, arquitectura, stack | 10 min |
| **[QUICKSTART.md](./QUICKSTART.md)** | Inicio rápido en 5 min | 5 min |
| **[ARCHITECTURE.md](./ARCHITECTURE.md)** | Diagramas, patrones, bases de datos | 15 min |
| **[API.md](./API.md)** | Documentación completa de endpoints | 20 min |

### 👨‍💻 Para Desarrolladores

| Documento | Contenido | Lectura |
|-----------|-----------|---------|
| **[DEVELOPMENT.md](./DEVELOPMENT.md)** | Setup local, testing, debugging | 30 min |
| **[TESTING.md](./TESTING.md)** | Ejemplos curl, casos de prueba | 10 min |
| **[CONTRIBUTING.md](./CONTRIBUTING.md)** | Cómo contribuir, pull requests | 15 min |

### 🚢 Para Deployment

| Documento | Contenido | Lectura |
|-----------|-----------|---------|
| **[DEPLOYMENT.md](./DEPLOYMENT.md)** | Checklist de deployment, health checks | 20 min |
| **[SUMMARY.md](./SUMMARY.md)** | Resumen ejecutivo, estadísticas | 10 min |

---

## 🎯 Guías por Caso de Uso

### "Quiero empezar rápido"
1. Lee [QUICKSTART.md](./QUICKSTART.md)
2. Ejecuta `docker-compose up --build`
3. Accede a http://localhost:3000

### "Quiero entender la arquitectura"
1. Lee [README.md](./README.md) - Visión general
2. Lee [ARCHITECTURE.md](./ARCHITECTURE.md) - Diagramas
3. Revisa código en `product-service/`, `order-service/`

### "Quiero desarrollar una feature"
1. Lee [DEVELOPMENT.md](./DEVELOPMENT.md) - Setup
2. Lee [CONTRIBUTING.md](./CONTRIBUTING.md) - Guía PR
3. Lee [API.md](./API.md) - Endpoints disponibles

### "Voy a hacer deploy"
1. Lee [DEPLOYMENT.md](./DEPLOYMENT.md) - Checklist
2. Ejecuta health checks
3. Haz tests de carga

### "Necesito probar APIs"
1. Lee [API.md](./API.md) - Documentación completa
2. Lee [TESTING.md](./TESTING.md) - Ejemplos curl
3. Accede a Swagger: http://localhost:8081/product-service/swagger-ui.html

---

## 📂 Estructura de Carpetas

```
ecommerce/
│
├── 📄 Documentación (Leer primero)
│   ├── README.md                 # Visión general
│   ├── QUICKSTART.md             # Inicio en 5 min
│   ├── ARCHITECTURE.md           # Diagramas y patrones
│   ├── API.md                    # Endpoints REST
│   ├── DEVELOPMENT.md            # Setup y testing
│   ├── TESTING.md                # Ejemplos curl
│   ├── DEPLOYMENT.md             # Deployment checklist
│   ├── CONTRIBUTING.md           # Cómo contribuir
│   └── SUMMARY.md                # Resumen ejecutivo
│
├── 🖥️ Backend (Java + Spring)
│   ├── api-gateway/              # Spring Cloud Gateway (8080)
│   ├── product-service/          # Servicio Productos (8081)
│   ├── order-service/            # Servicio Órdenes (8082)
│   ├── build.gradle.kts          # Config multi-módulo
│   └── settings.gradle.kts       # Submódulos
│
├── 💻 Frontend (React)
│   └── frontend/                 # React 18 app (3000)
│       ├── src/pages/            # Componentes principales
│       ├── src/api/              # Cliente HTTP
│       └── package.json          # Dependencias npm
│
├── 🐳 Containerización
│   ├── docker-compose.yml        # Orquestación completa
│   └── [service]/Dockerfile      # Dockerfile de cada servicio
│
├── 🔧 Configuración
│   ├── .env.example              # Variables de entorno
│   ├── .gitignore                # Git ignore
│   ├── start-local.sh            # Script de inicio
│   └── cleanup.sh                # Script de limpieza
│
└── 📦 Base de Datos
    └── PostgreSQL                # Dos instancias (product, order)
```

---

## 🔑 Conceptos Clave

### Arquitectura de Microservicios

```
Clientes HTTP
    ↓
API Gateway (8080)
    ↓
    ├── Product Service (8081)
    │   └── PostgreSQL product_db
    │
    └── Order Service (8082)
        ├── OpenFeign Client → Product Service
        └── PostgreSQL order_db
```

### Patrones Implementados

- **Circuit Breaker**: Resilience4j en Order Service
- **OpenFeign**: Comunicación inter-servicios
- **API Gateway**: Enrutamiento centralizado
- **Repository**: Acceso a datos con Spring Data JPA
- **Service Layer**: Lógica de negocio centralizada
- **DTO**: Separación request/response

### Tecnologías

- **Backend**: Java 21, Spring Boot 3.2+, Spring Cloud
- **Frontend**: React 18, Axios, Bootstrap
- **Base de Datos**: PostgreSQL 15
- **Containerización**: Docker, Docker Compose

---

## 📞 Navegación Rápida

| Necesito... | Ir a... |
|------------|---------|
| Empezar en 5 min | [QUICKSTART.md](./QUICKSTART.md) |
| Entender arquitectura | [ARCHITECTURE.md](./ARCHITECTURE.md) |
| Ver endpoints API | [API.md](./API.md) |
| Instalar localmente | [DEVELOPMENT.md](./DEVELOPMENT.md) |
| Probar con curl | [TESTING.md](./TESTING.md) |
| Hacer deploy | [DEPLOYMENT.md](./DEPLOYMENT.md) |
| Contribuir código | [CONTRIBUTING.md](./CONTRIBUTING.md) |
| Ver resumen general | [SUMMARY.md](./SUMMARY.md) |

---

## ✨ Características Principales

✅ **Microservicios escalables**
- Product Service con CRUD completo
- Order Service con integración HTTP
- API Gateway con enrutamiento

✅ **Resiliencia**
- Circuit Breaker pattern
- Fallback methods
- Error handling robusto

✅ **Base de Datos**
- PostgreSQL para cada servicio
- Auto-schema creation con JPA
- Migrations automáticas

✅ **Frontend**
- React con React Router
- Catálogo de productos
- Carrito de compras
- Gestión de órdenes

✅ **DevOps**
- Docker & Docker Compose
- Health checks configurados
- Logs centralizados

✅ **Testing**
- Tests unitarios con JUnit 5
- Mocking con Mockito
- 16+ test cases

✅ **Documentación**
- 8 archivos markdown
- Swagger/OpenAPI en cada servicio
- Ejemplos curl
- Diagramas de arquitectura

---

## 🚀 URLs Importantes

| Servicio | URL | Descripción |
|----------|-----|-------------|
| **Frontend** | http://localhost:3000 | Aplicación web |
| **API Gateway** | http://localhost:8080 | Punto entrada |
| **Product Service** | http://localhost:8081/product-service | Swagger |
| **Order Service** | http://localhost:8082/order-service | Swagger |
| **PostgreSQL Product** | localhost:5432 | BD product_db |
| **PostgreSQL Order** | localhost:5433 | BD order_db |

---

## 📊 Estadísticas del Proyecto

```
Microservicios:     3
Bases de Datos:     2
Endpoints REST:     13+
Archivos Java:      40+
Componentes React:  10+
Test Cases:         16+
Documentación:      8 archivos markdown
Líneas de Código:   5000+ (sin contar build)
```

---

## 🎓 Stack Tecnológico

### Backend
- Java 21
- Spring Boot 3.2.0
- Spring Cloud 2023.0.0
- Spring Data JPA
- PostgreSQL 15
- Resilience4j
- OpenFeign
- SpringDoc OpenAPI
- Gradle 8+

### Frontend
- React 18
- React Router 6
- Axios
- Bootstrap 5
- CSS3

### DevOps
- Docker
- Docker Compose

---

## ❓ FAQ

**P: ¿Por dónde empiezo?**
R: Lee [QUICKSTART.md](./QUICKSTART.md) para empezar en 5 minutos.

**P: ¿Cómo configuro el ambiente local?**
R: Sigue [DEVELOPMENT.md](./DEVELOPMENT.md) paso a paso.

**P: ¿Cómo se comunican los servicios?**
R: Lee [ARCHITECTURE.md](./ARCHITECTURE.md) para diagramas detallados.

**P: ¿Qué endpoints están disponibles?**
R: Consulta [API.md](./API.md) para documentación completa.

**P: ¿Cómo contribuyo?**
R: Lee [CONTRIBUTING.md](./CONTRIBUTING.md) para guía de contribución.

**P: ¿Cómo hago deploy?**
R: Sigue [DEPLOYMENT.md](./DEPLOYMENT.md) checklist.

---

## 📝 Historial de Cambios

**Versión 1.0.0** (Abril 27, 2024)
- ✅ Arquitectura multi-microservicio completa
- ✅ Product Service con CRUD
- ✅ Order Service con integración
- ✅ API Gateway con Circuit Breaker
- ✅ Frontend React
- ✅ Docker Compose
- ✅ Documentación completa
- ✅ Tests unitarios

---

## 🤝 Contribuir

¿Quieres contribuir? Lee [CONTRIBUTING.md](./CONTRIBUTING.md) para las guías.

Áreas donde se necesita ayuda:
- Testing (más cobertura)
- Frontend (UI/UX improvements)
- DevOps (CI/CD setup)
- Documentación (traducción)

---

## 📄 Licencia

MIT License - Ver LICENSE file

---

## 🎉 ¡Gracias!

Gracias por usar esta plataforma E-commerce. 

Si tienes preguntas, abre un issue.
Si encuentras bugs, reporta en Issues.
Si quieres mejorar, haz un Pull Request.

**Happy Coding! 🚀**

---

**Última actualización:** Abril 27, 2024
**Versión:** 1.0.0
**Mantenedor:** Tu Nombre/Equipo

