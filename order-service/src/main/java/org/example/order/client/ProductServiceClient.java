package org.example.order.client;

import org.example.order.dto.ProductDTO;
import org.example.order.exception.ServiceUnavailableException;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Feign Client para consumir el Product Service.
 * Incluye fallback automático en caso de indisponibilidad.
 */
@FeignClient(
    name = "product-service",
    url = "${clients.product-service.url:http://product-service:8081/product-service}",
    fallback = ProductServiceClientFallback.class
)
public interface ProductServiceClient {

    /**
     * Obtiene todos los productos disponibles.
     * @return Lista de productos
     */
    @GetMapping("/api/products")
    List<ProductDTO> getAllProducts();

    /**
     * Obtiene un producto por su ID.
     * @param id ID del producto
     * @return Datos del producto
     */
    @GetMapping("/api/products/{id}")
    ProductDTO getProductById(@PathVariable Long id);

    /**
     * Reserva stock de un producto para una orden.
     * @param id ID del producto
     * @param quantity Cantidad a reservar
     */
    @PostMapping("/api/products/{id}/reserve")
    void reserveStock(@PathVariable Long id, @RequestParam Integer quantity);

    /**
     * Libera stock reservado de un producto.
     * @param id ID del producto
     * @param quantity Cantidad a liberar
     */
    @PostMapping("/api/products/{id}/release")
    void releaseStock(@PathVariable Long id, @RequestParam Integer quantity);

    /**
     * Actualiza el stock de un producto.
     * @param id ID del producto
     * @param quantity Nueva cantidad de stock
     * @return Datos actualizados del producto
     */
    @PutMapping("/api/products/{id}/stock")
    ProductDTO updateStock(@PathVariable Long id, @RequestParam Integer quantity);
}


/**
 * Implementación de fallback para ProductServiceClient.
 * Se activa automáticamente cuando el Product Service no está disponible.
 * Implementa el patrón Circuit Breaker.
 */
@Component
class ProductServiceClientFallback implements ProductServiceClient {

    private static final String SERVICE_UNAVAILABLE_MESSAGE = "Product Service is temporarily unavailable. Please try again later.";

    @Override
    public List<ProductDTO> getAllProducts() {
        throw new ServiceUnavailableException(SERVICE_UNAVAILABLE_MESSAGE);
    }

    @Override
    public ProductDTO getProductById(Long id) {
        throw new ServiceUnavailableException(SERVICE_UNAVAILABLE_MESSAGE + " Cannot fetch product with id: " + id);
    }

    @Override
    public void reserveStock(Long id, Integer quantity) {
        throw new ServiceUnavailableException(SERVICE_UNAVAILABLE_MESSAGE + " Cannot reserve stock for product id: " + id);
    }

    @Override
    public void releaseStock(Long id, Integer quantity) {
        throw new ServiceUnavailableException(SERVICE_UNAVAILABLE_MESSAGE + " Cannot release stock for product id: " + id);
    }

    @Override
    public ProductDTO updateStock(Long id, Integer quantity) {
        throw new ServiceUnavailableException(SERVICE_UNAVAILABLE_MESSAGE + " Cannot update stock for product id: " + id);
    }
}

