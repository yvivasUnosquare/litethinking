package org.example.order.exception;

/**
 * Excepción lanzada cuando no hay stock suficiente para una orden.
 */
public class InsufficientStockException extends RuntimeException {

    private final Long productId;

    public InsufficientStockException(Long productId) {
        super("Insufficient stock for product with id: " + productId);
        this.productId = productId;
    }

    public InsufficientStockException(Long productId, String message) {
        super(message);
        this.productId = productId;
    }

    public Long getProductId() {
        return productId;
    }
}

