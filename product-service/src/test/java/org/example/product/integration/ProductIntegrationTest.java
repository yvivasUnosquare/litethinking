package org.example.product.integration;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.example.product.dto.ProductDTO;
import org.example.product.entity.Product;
import org.example.product.repository.ProductRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import static org.hamcrest.Matchers.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * Prueba de integración para Product Service.
 * Prueba el flujo completo desde el controlador hasta la base de datos.
 */
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
@ActiveProfiles("test")
class ProductIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private ObjectMapper objectMapper;

    private Product testProduct;

    @BeforeEach
    void setUp() {
        productRepository.deleteAll();
        
        testProduct = Product.builder()
                .name("Integration Test Product")
                .description("This is a test product")
                .category("Electronics")
                .price(new java.math.BigDecimal("49.99"))
                .stock(100)
                .build();
        
        testProduct = productRepository.save(testProduct);
    }

    @Test
    void testGetAllProducts_ReturnsProductsList() throws Exception {
        mockMvc.perform(get("/api/products"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].name", is("Integration Test Product")))
                .andExpect(jsonPath("$[0].price", is(49.99)))
                .andExpect(jsonPath("$[0].stock", is(100)));
    }

    @Test
    void testGetProductById_ReturnsProduct() throws Exception {
        mockMvc.perform(get("/api/products/{id}", testProduct.getId()))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.name", is("Integration Test Product")))
                .andExpect(jsonPath("$.category", is("Electronics")));
    }

    @Test
    void testGetProductById_NotFound_Returns404() throws Exception {
        mockMvc.perform(get("/api/products/{id}", 99999L))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.status", is(404)))
                .andExpect(jsonPath("$.error", containsString("not found")));
    }

    @Test
    void testCreateProduct_Success() throws Exception {
        ProductDTO newProduct = ProductDTO.builder()
                .name("New Product")
                .description("Brand new product")
                .category("Books")
                .price(new java.math.BigDecimal("29.99"))
                .stock(50)
                .build();

        mockMvc.perform(post("/api/products")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(newProduct)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.name", is("New Product")))
                .andExpect(jsonPath("$.price", is(29.99)))
                .andExpect(jsonPath("$.id", notNullValue()));
    }

    @Test
    void testCreateProduct_ValidationError_Returns400() throws Exception {
        ProductDTO invalidProduct = ProductDTO.builder()
                .name("") // nombre vacío, debería fallar validación
                .price(new java.math.BigDecimal("-10.0")) // precio negativo
                .stock(-5) // stock negativo
                .build();

        mockMvc.perform(post("/api/products")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(invalidProduct)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.status", is(400)))
                .andExpect(jsonPath("$.errors", notNullValue()));
    }

    @Test
    void testUpdateProduct_Success() throws Exception {
        ProductDTO updatedProduct = ProductDTO.builder()
                .name("Updated Product Name")
                .description("Updated description")
                .category("Electronics")
                .price(new java.math.BigDecimal("59.99"))
                .stock(150)
                .build();

        mockMvc.perform(put("/api/products/{id}", testProduct.getId())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(updatedProduct)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.name", is("Updated Product Name")))
                .andExpect(jsonPath("$.price", is(59.99)))
                .andExpect(jsonPath("$.stock", is(150)));
    }

    @Test
    void testDeleteProduct_Success() throws Exception {
        mockMvc.perform(delete("/api/products/{id}", testProduct.getId()))
                .andExpect(status().isNoContent());

        // Verificar que el producto ya no existe
        mockMvc.perform(get("/api/products/{id}", testProduct.getId()))
                .andExpect(status().isNotFound());
    }

    @Test
    void testReserveStock_Success() throws Exception {
        mockMvc.perform(post("/api/products/{id}/reserve", testProduct.getId())
                        .param("quantity", "10"))
                .andExpect(status().isOk());

        // Verificar que el stock se redujo
        mockMvc.perform(get("/api/products/{id}", testProduct.getId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.stock", is(90)));
    }

    @Test
    void testReserveStock_InsufficientStock_Returns409() throws Exception {
        mockMvc.perform(post("/api/products/{id}/reserve", testProduct.getId())
                        .param("quantity", "200"))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.status", is(409)))
                .andExpect(jsonPath("$.error", containsString("Insufficient stock")));
    }

    @Test
    void testReleaseStock_Success() throws Exception {
        // Primero reservar stock
        productRepository.save(testProduct);

        mockMvc.perform(post("/api/products/{id}/release", testProduct.getId())
                        .param("quantity", "10"))
                .andExpect(status().isOk());

        // Verificar que el stock aumentó
        mockMvc.perform(get("/api/products/{id}", testProduct.getId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.stock", is(110)));
    }

    @Test
    void testCompleteProductLifecycle() throws Exception {
        // 1. Crear producto
        ProductDTO newProduct = ProductDTO.builder()
                .name("Lifecycle Product")
                .description("Product for lifecycle test")
                .category("Toys")
                .price(new java.math.BigDecimal("99.99"))
                .stock(20)
                .build();

        String createResponse = mockMvc.perform(post("/api/products")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(newProduct)))
                .andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString();

        ProductDTO createdProduct = objectMapper.readValue(createResponse, ProductDTO.class);
        Long productId = createdProduct.getId();

        // 2. Obtener producto
        mockMvc.perform(get("/api/products/{id}", productId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.name", is("Lifecycle Product")));

        // 3. Reservar stock
        mockMvc.perform(post("/api/products/{id}/reserve", productId)
                        .param("quantity", "5"))
                .andExpect(status().isOk());

        // 4. Verificar stock reducido
        mockMvc.perform(get("/api/products/{id}", productId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.stock", is(15)));

        // 5. Actualizar producto
        newProduct.setPrice(new java.math.BigDecimal("89.99"));
        mockMvc.perform(put("/api/products/{id}", productId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(newProduct)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.price", is(89.99)));

        // 6. Eliminar producto
        mockMvc.perform(delete("/api/products/{id}", productId))
                .andExpect(status().isNoContent());

        // 7. Verificar que ya no existe
        mockMvc.perform(get("/api/products/{id}", productId))
                .andExpect(status().isNotFound());
    }
}






