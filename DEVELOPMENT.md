# Guía de Desarrollo

## Requisitos del Sistema

- **Java Development Kit (JDK) 21+**
  ```bash
  java -version
  # openjdk version "21.x.x"
  ```

- **Gradle 8.0+** (incluido con gradlew)
  ```bash
  ./gradlew --version
  ```

- **Node.js 18+** (para frontend)
  ```bash
  node --version
  npm --version
  ```

- **Docker & Docker Compose**
  ```bash
  docker --version
  docker-compose --version
  ```

- **PostgreSQL 15** (para desarrollo local, o usar Docker)

## Setup Local

### 1. Clonar Repositorio

```bash
git clone <repository-url>
cd ecommerce
```

### 2. Instalar Dependencias

```bash
# Backend (Gradle descarga automáticamente)
./gradlew build

# Frontend
cd frontend
npm install
cd ..
```

### 3. Configurar Base de Datos

**Opción A: Usar Docker**

```bash
docker run -d --name postgres-product \
  -e POSTGRES_DB=product_db \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -p 5432:5432 \
  postgres:15-alpine

docker run -d --name postgres-order \
  -e POSTGRES_DB=order_db \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -p 5433:5432 \
  postgres:15-alpine
```

**Opción B: PostgreSQL Local**

Crear las bases de datos:

```sql
-- Conectarse como postgres
psql -U postgres

-- Crear bases de datos
CREATE DATABASE product_db;
CREATE DATABASE order_db;

-- Verificar
\l
```

Actualizar connection strings en `application.yml`:

```yaml
spring.datasource.url: jdbc:postgresql://localhost:5432/product_db
# o
spring.datasource.url: jdbc:postgresql://localhost:5433/order_db
```

### 4. Ejecutar Servicios

**Terminal 1: Product Service**

```bash
./gradlew :product-service:bootRun
# Escucha en http://localhost:8081
# Swagger: http://localhost:8081/product-service/swagger-ui.html
```

**Terminal 2: Order Service**

```bash
./gradlew :order-service:bootRun
# Escucha en http://localhost:8082
# Swagger: http://localhost:8082/order-service/swagger-ui.html
```

**Terminal 3: API Gateway**

```bash
./gradlew :api-gateway:bootRun
# Escucha en http://localhost:8080
```

**Terminal 4: Frontend**

```bash
cd frontend
npm start
# Abre http://localhost:3000
```

## Estructura de Directorios

### Backend

```
product-service/
├── src/main/java/org/example/product/
│   ├── ProductServiceApplication.java    # Main
│   ├── controller/
│   │   └── ProductController.java
│   ├── service/
│   │   └── ProductService.java
│   ├── entity/
│   │   └── Product.java
│   ├── repository/
│   │   └── ProductRepository.java
│   ├── dto/
│   │   └── ProductDTO.java
│   └── exception/
│       ├── ProductNotFoundException.java
│       ├── InsufficientStockException.java
│       └── GlobalExceptionHandler.java
├── src/main/resources/
│   └── application.yml
├── src/test/java/org/example/product/
│   └── service/
│       └── ProductServiceTest.java
└── Dockerfile
```

Similar para order-service y api-gateway.

### Frontend

```
frontend/
├── src/
│   ├── pages/
│   │   ├── ProductCatalog.js
│   │   ├── Cart.js
│   │   ├── Checkout.js
│   │   └── Orders.js
│   ├── api/
│   │   └── apiClient.js        # Axios configurado
│   ├── App.js
│   ├── App.css
│   └── index.js
├── public/
│   └── index.html
├── package.json
└── Dockerfile
```

## Convenciones de Código

### Java

- **Naming**: camelCase para variables/métodos, PascalCase para clases
- **Imports**: Organizar alfabéticamente
- **Annotations**: Spring annotations sobre la clase/método
- **DTOs**: Siempre usar para request/response
- **Exceptions**: Custom exceptions heredando de RuntimeException

Ejemplo:

```java
@RestController
@RequestMapping("/api/products")
@RequiredArgsConstructor
public class ProductController {
    private final ProductService productService;

    @GetMapping("/{id}")
    public ResponseEntity<ProductDTO> getById(@PathVariable Long id) {
        return ResponseEntity.ok(productService.getProductById(id));
    }
}
```

### JavaScript/React

- **Components**: Functional components con hooks
- **Naming**: PascalCase para componentes, camelCase para variables
- **Imports**: React primero, luego componentes
- **Props**: Desestructuración en parámetros

Ejemplo:

```javascript
function ProductCatalog({ onAddToCart }) {
  const [products, setProducts] = useState([]);

  useEffect(() => {
    fetchProducts();
  }, []);

  const fetchProducts = async () => {
    // ...
  };

  return (
    <div>
      {/* JSX aquí */}
    </div>
  );
}
```

## Testing

### Ejecutar Tests

```bash
# Todos los tests
./gradlew test

# Tests específicos
./gradlew :product-service:test
./gradlew :order-service:test

# Con output detallado
./gradlew test --info
```

### Estructura de Tests

```java
@ExtendWith(MockitoExtension.class)
class ProductServiceTest {
    @Mock
    private ProductRepository productRepository;

    @InjectMocks
    private ProductService productService;

    @BeforeEach
    void setUp() {
        // Inicialización
    }

    @Test
    void testMethodName() {
        // Arrange
        when(productRepository.findById(1L))
            .thenReturn(Optional.of(product));

        // Act
        ProductDTO result = productService.getProductById(1L);

        // Assert
        assertNotNull(result);
        verify(productRepository, times(1)).findById(1L);
    }
}
```

### Cobertura

```bash
./gradlew test jacocoTestReport
# Reporte en: build/reports/jacoco/test/html/index.html
```

## Build y Deployment

### Compilar JAR

```bash
./gradlew :product-service:bootJar
./gradlew :order-service:bootJar
./gradlew :api-gateway:bootJar

# JARs generados en:
# product-service/build/libs/product-service-*.jar
# order-service/build/libs/order-service-*.jar
# api-gateway/build/libs/api-gateway-*.jar
```

### Docker

```bash
# Build una imagen específica
docker build -t product-service:1.0 ./product-service

# Ejecutar contenedor
docker run -p 8081:8081 \
  -e SPRING_DATASOURCE_URL=jdbc:postgresql://host.docker.internal:5432/product_db \
  product-service:1.0

# Docker Compose (recomendado)
docker-compose up --build
```

## Debugging

### IntelliJ IDEA

1. Abrir proyecto en IntelliJ
2. Run → Edit Configurations
3. Agregar "Gradle" configuration:
   - Tasks: `:product-service:bootRun`
   - VM Options: `-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005`
4. Run con Debug

### VS Code

Crear `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "java",
      "name": "Product Service",
      "request": "launch",
      "mainClass": "org.example.product.ProductServiceApplication",
      "projectName": "product-service",
      "cwd": "${workspaceFolder}",
      "console": "integratedTerminal"
    }
  ]
}
```

## Documentación API

### Swagger/OpenAPI

Cada servicio expone Swagger en:

```
Product Service: http://localhost:8081/product-service/swagger-ui.html
Order Service: http://localhost:8082/order-service/swagger-ui.html
```

Para agregar documentación a un endpoint:

```java
@GetMapping("/{id}")
@Operation(summary = "Get product by ID")
@ApiResponse(responseCode = "200", description = "Product found")
@ApiResponse(responseCode = "404", description = "Product not found")
public ResponseEntity<ProductDTO> getById(@PathVariable Long id) {
    // ...
}
```

## Troubleshooting

### Puerto ya está en uso

```bash
# macOS/Linux - encontrar proceso
lsof -i :8080

# Matar proceso
kill -9 <PID>

# Windows
netstat -ano | findstr :8080
taskkill /PID <PID> /F
```

### Base de datos no responde

```bash
# Verificar contenedores Docker
docker ps -a

# Ver logs
docker logs postgres-product
docker logs postgres-order

# Reiniciar
docker restart postgres-product postgres-order
```

### Frontend no conecta con API

```bash
# Verificar que Gateway esté corriendo en 8080
curl http://localhost:8080

# Verificar CORS headers
curl -i http://localhost:8080/api/products

# Revisar console del navegador (F12)
# Mirar Network tab para requests
```

### Build falla

```bash
# Limpiar cache Gradle
./gradlew clean

# Rebuild desde cero
./gradlew build --refresh-dependencies

# Ver más detalles
./gradlew build --debug
```

## Flujo de Desarrollo Típico

1. **Crear rama**
   ```bash
   git checkout -b feature/mi-feature
   ```

2. **Hacer cambios**
   - Implementar feature
   - Escribir tests
   - Actualizar documentación

3. **Testear localmente**
   ```bash
   ./gradlew test
   docker-compose up --build
   ```

4. **Commit**
   ```bash
   git add .
   git commit -m "feat: descripción del cambio"
   ```

5. **Push y Pull Request**
   ```bash
   git push origin feature/mi-feature
   # Crear PR en GitHub
   ```

## Performance Tips

- Usar índices en BD para campos buscados frecuentemente
- Implementar paginación para listados grandes
- Cachear productos que no cambian frecuentemente
- Usar lazy loading para relaciones
- Optimizar queries N+1 con JOIN FETCH

## Seguridad

Antes de deployment a producción:

- [ ] Cambiar contraseñas por defecto de BD
- [ ] Configurar HTTPS/TLS
- [ ] Implementar autenticación (JWT)
- [ ] Validar y sanitizar inputs
- [ ] Usar prepared statements (ya se hace con JPA)
- [ ] Configurar CORS apropiadamente
- [ ] Rate limiting en API Gateway
- [ ] Logging de acceso y errores

## Resources Útiles

- [Spring Boot Docs](https://spring.io/projects/spring-boot)
- [Spring Cloud Gateway](https://spring.io/projects/spring-cloud-gateway)
- [Resilience4j](https://resilience4j.readme.io/)
- [React Docs](https://react.dev)
- [PostgreSQL Docs](https://www.postgresql.org/docs/)
- [Docker Docs](https://docs.docker.com/)

