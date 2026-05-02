# 💡 Tips y Mejores Prácticas

## Backend (Java/Spring)

### ✅ Mejores Prácticas Implementadas

#### 1. Validación de Entrada
```java
// ✅ Correcto - Validación en DTO
@Data
public class ProductDTO {
    @NotBlank(message = "Name is required")
    private String name;
    
    @Positive(message = "Price must be > 0")
    private Double price;
}

// En Controller
@PostMapping
public ResponseEntity<ProductDTO> create(@Valid @RequestBody ProductDTO dto) {
    // Validación automática
}
```

#### 2. Exception Handling
```java
// ✅ Correcto - Custom exceptions
try {
    product = findProduct(id);
} catch (ProductNotFoundException ex) {
    throw new ProductNotFoundException("Not found: " + id);
}

// Global handler
@RestControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(ProductNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(ProductNotFoundException ex) {
        return ResponseEntity.notFound().build();
    }
}
```

#### 3. Transacciones
```java
// ✅ Correcto - Transacciones explícitas
@Service
@RequiredArgsConstructor
@Transactional
public class OrderService {
    public void createOrder(OrderDTO dto) {
        // Toda la operación es atómica
    }
    
    // Si necesitas read-only
    @Transactional(readOnly = true)
    public OrderDTO getOrder(Long id) {
        // ...
    }
}
```

#### 4. OpenFeign Client
```java
// ✅ Correcto - Con Circuit Breaker
@FeignClient(name = "product-service", 
             url = "${product-service.url}")
public interface ProductServiceClient {
    @GetMapping("/api/products/{id}")
    ProductDTO getProduct(@PathVariable Long id);
}

// Uso con resilience
@Service
@CircuitBreaker(name = "productService", 
                fallbackMethod = "fallback")
public void reserveStock(Long id, Integer qty) {
    productServiceClient.reserve(id, qty);
}

public void fallback(Long id, Integer qty, Exception ex) {
    throw new ServiceUnavailableException("Product Service down");
}
```

### 🔧 Tips de Optimización

#### 1. Lazy Loading para Relaciones
```java
// ✅ Evita N+1 queries
@Entity
public class Order {
    @OneToMany(mappedBy = "order", fetch = FetchType.LAZY)
    // Solo carga cuando accedes a items
    private List<OrderItem> items;
}

// Mejor aún: JOIN FETCH en queries específicas
@Query("SELECT o FROM Order o LEFT JOIN FETCH o.items WHERE o.id = :id")
Optional<Order> findByIdWithItems(@Param("id") Long id);
```

#### 2. Connection Pooling
```yaml
# application.yml
spring:
  datasource:
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      idle-timeout: 600000
      max-lifetime: 1800000
```

#### 3. Índices en Base de Datos
```java
@Entity
@Table(name = "products", indexes = {
    @Index(name = "idx_sku", columnList = "sku"),
    @Index(name = "idx_status", columnList = "status")
})
public class Product {
    @Column(unique = true)
    private String sku;
}
```

---

## Frontend (React)

### ✅ Mejores Prácticas Implementadas

#### 1. Hooks y Estado
```javascript
// ✅ Correcto - Estados independientes
function ProductList() {
    const [products, setProducts] = useState([]);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState(null);

    useEffect(() => {
        fetchProducts();
    }, []);

    return (
        <div>
            {loading && <Spinner />}
            {error && <Alert>{error}</Alert>}
            {/* Content */}
        </div>
    );
}
```

#### 2. API Client Centralizado
```javascript
// ✅ Correcto - Reutilizable
export const productService = {
    getAll: () => api.get('/api/products'),
    getById: (id) => api.get(`/api/products/${id}`),
    create: (data) => api.post('/api/products', data),
};

// Uso
const [products, setProducts] = useState([]);

useEffect(() => {
    productService.getAll()
        .then(res => setProducts(res.data))
        .catch(err => console.error(err));
}, []);
```

#### 3. Error Handling
```javascript
// ✅ Correcto - Error handling robusto
async function fetchData() {
    try {
        setLoading(true);
        const response = await api.get('/api/products');
        setData(response.data);
        setError(null);
    } catch (err) {
        if (err.response?.status === 404) {
            setError('Not found');
        } else if (err.response?.status === 503) {
            setError('Service unavailable. Retry later.');
        } else {
            setError('An error occurred');
        }
    } finally {
        setLoading(false);
    }
}
```

#### 4. Componentes Reutilizables
```javascript
// ✅ Correcto - Componente genérico
function DataTable({ data, columns, loading, error, onEdit, onDelete }) {
    return (
        <div>
            {loading && <Spinner />}
            {error && <Alert variant="danger">{error}</Alert>}
            <Table>
                {/* Render based on columns */}
            </Table>
        </div>
    );
}

// Uso
<DataTable
    data={products}
    columns={productColumns}
    loading={loading}
    error={error}
    onEdit={editProduct}
    onDelete={deleteProduct}
/>
```

### 🔧 Tips de Optimización

#### 1. Memoización
```javascript
// ✅ Evita re-renders innecesarios
const ProductCard = React.memo(({ product, onAdd }) => {
    return (
        <Card>
            <h5>{product.name}</h5>
            <button onClick={() => onAdd(product)}>Add</button>
        </Card>
    );
}, (prevProps, nextProps) => {
    return prevProps.product.id === nextProps.product.id;
});
```

#### 2. Lazy Loading
```javascript
// ✅ Code splitting
const AdminPanel = React.lazy(() => import('./AdminPanel'));

function App() {
    return (
        <Suspense fallback={<Spinner />}>
            <AdminPanel />
        </Suspense>
    );
}
```

#### 3. Caché Local
```javascript
// ✅ Evitar llamadas repetidas
const productCache = new Map();

async function getProduct(id) {
    if (productCache.has(id)) {
        return productCache.get(id);
    }
    
    const data = await api.get(`/api/products/${id}`);
    productCache.set(id, data.data);
    return data.data;
}
```

---

## Database (PostgreSQL)

### ✅ Mejores Prácticas

#### 1. Índices Apropiados
```sql
-- ✅ Correcto - Para búsquedas frecuentes
CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_order_items_product ON order_items(product_id);

-- Ver índices
SELECT * FROM pg_indexes WHERE tablename = 'products';
```

#### 2. Foreign Keys
```sql
-- ✅ Correcto - Mantener integridad referencial
ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_order
FOREIGN KEY (order_id) REFERENCES orders(id)
ON DELETE CASCADE;
```

#### 3. Backups
```bash
# ✅ Backup regular
pg_dump -U postgres -d product_db > backup_$(date +%Y%m%d).sql

# Restore
psql -U postgres -d product_db < backup_20240427.sql
```

---

## Testing

### ✅ Mejores Prácticas

#### 1. AAA Pattern
```java
// ✅ Arrange, Act, Assert
@Test
void testGetProductById() {
    // Arrange
    Long productId = 1L;
    Product expected = createTestProduct();
    when(repository.findById(productId))
        .thenReturn(Optional.of(expected));
    
    // Act
    ProductDTO result = service.getProductById(productId);
    
    // Assert
    assertNotNull(result);
    assertEquals(expected.getName(), result.getName());
}
```

#### 2. Test Coverage
```bash
# Ejecutar con cobertura
./gradlew test jacocoTestReport

# Ver reporte
open build/reports/jacoco/test/html/index.html

# Target: 80%+ coverage para código crítico
```

#### 3. Fixtures/Builders
```java
// ✅ Evita repetición
public class ProductTestDataBuilder {
    private String name = "Test Product";
    private Double price = 99.99;
    
    public ProductTestDataBuilder withName(String name) {
        this.name = name;
        return this;
    }
    
    public Product build() {
        return new Product(name, price, ...);
    }
}

// Uso
Product product = new ProductTestDataBuilder()
    .withName("iPhone")
    .build();
```

---

## DevOps & Deployment

### ✅ Mejores Prácticas

#### 1. Environment Variables
```bash
# ✅ No hardcodear configuración
# .env.example (versionado)
DATABASE_URL=postgresql://localhost:5432/product_db
API_KEY=your-key-here

# .env (local, no versionado)
# Copiar de .env.example y reemplazar

# En código
String dbUrl = System.getenv("DATABASE_URL");
```

#### 2. Health Checks
```yaml
# application.yml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics
  endpoint:
    health:
      show-details: always
```

```bash
# Verificar estado
curl http://localhost:8080/actuator/health
# { "status": "UP" }
```

#### 3. Logging
```java
// ✅ No System.out.println
private static final Logger logger = LoggerFactory.getLogger(OrderService.class);

public void createOrder(OrderDTO dto) {
    logger.info("Creating order with {} items", dto.getItems().size());
    try {
        // Logic
        logger.debug("Order created: {}", orderId);
    } catch (Exception ex) {
        logger.error("Failed to create order", ex);
        throw ex;
    }
}
```

---

## Seguridad

### ✅ Implementado

#### 1. Input Validation
```java
// ✅ Validación en múltiples niveles
@PostMapping
public ResponseEntity<ProductDTO> create(
    @Valid @RequestBody ProductDTO dto  // Validación 1
) {
    // Validación 2: Lógica adicional
    if (dto.getPrice() > MAX_PRICE) {
        throw new PriceExceededException();
    }
    return ResponseEntity.created(...).build();
}
```

#### 2. Exception Messages
```java
// ✅ No exponer detalles internos
throw new ProductNotFoundException("Product not found");

// ❌ Evitar
throw new Exception("Database error: " + ex.getMessage());
```

### 🔄 Recomendaciones para Producción

#### 1. Autenticación
```java
// Agregar Spring Security + JWT
@Configuration
@EnableWebSecurity
public class SecurityConfig {
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) {
        http.authorizeRequests()
            .antMatchers("/api/products/**").permitAll()
            .antMatchers("/api/orders/**").authenticated()
            .and()
            .oauth2ResourceServer().jwt();
        return http.build();
    }
}
```

#### 2. HTTPS
```yaml
# application.yml
server:
  ssl:
    key-store: classpath:keystore.p12
    key-store-password: ${SSL_KEYSTORE_PASSWORD}
    key-store-type: PKCS12
```

#### 3. Rate Limiting
```java
// Agregar Spring Cloud Gateway rate limit
@Configuration
public class GatewayConfig {
    @Bean
    public RouteLocator routes(RouteLocatorBuilder builder) {
        return builder.routes()
            .route("product-service", r -> r
                .path("/api/products/**")
                .filters(f -> f.requestRateLimiter(c -> 
                    c.setRateLimiter(redisRateLimiter())))
                .uri("http://product-service:8081"))
            .build();
    }
}
```

---

## Performance Tips

### Backend
- Usar índices en campos buscados
- Implementar paginación
- Cachear datos estáticos
- Connection pooling configurado

### Frontend
- Code splitting con React.lazy
- Memoización de componentes
- Lazy loading de imágenes
- Minimización de bundle

### Database
- Análisis de queries lentas
- VACUUM y ANALYZE regular
- Backups automáticos
- Replicación si es crítico

---

## Debugging

### Backend
```bash
# Logs en tiempo real
docker-compose logs -f product-service

# Debug mode en Gradle
./gradlew bootRun --debug-jvm

# Ver queries SQL
logging:
  level:
    org.hibernate.SQL: DEBUG
    org.hibernate.type.descriptor.sql: TRACE
```

### Frontend
```javascript
// DevTools
- F12 en navegador
- Console tab para errores
- Network tab para requests
- React DevTools extension

// Logging
console.log('Debug:', data);
console.error('Error:', error);
```

### Database
```bash
# Conectar a BD
docker exec -it postgres-product psql -U postgres -d product_db

# Ver logs
docker logs postgres-product

# Ver conexiones
SELECT * FROM pg_stat_activity;
```

---

## Checklist Pre-Production

- [ ] Todos los tests pasan
- [ ] Cobertura de tests >80%
- [ ] Documentación actualizada
- [ ] No hay hardcoded secrets
- [ ] Logs configurados
- [ ] Health checks funcionan
- [ ] Error handling robusto
- [ ] Validación de inputs completa
- [ ] HTTPS configurado
- [ ] Rate limiting en lugar
- [ ] Backups automáticos
- [ ] Monitoring setup
- [ ] Alertas configuradas
- [ ] Disaster recovery plan

---

## Recursos Útiles

### Java/Spring
- [Spring Boot Official Docs](https://spring.io/projects/spring-boot)
- [Spring Cloud Documentation](https://spring.io/projects/spring-cloud)
- [Resilience4j Patterns](https://resilience4j.readme.io/)

### React
- [React Official Docs](https://react.dev)
- [React Router](https://reactrouter.com/)
- [Axios Documentation](https://axios-http.com/)

### Database
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [PostgreSQL Performance Tips](https://wiki.postgresql.org/wiki/Performance_Optimization)

### DevOps
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Kubernetes Tutorials](https://kubernetes.io/docs/tutorials/)

---

**Última actualización:** Abril 27, 2024

