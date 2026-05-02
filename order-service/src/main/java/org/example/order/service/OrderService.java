package org.example.order.service;

import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.order.client.ProductServiceClient;
import org.example.order.dto.OrderDTO;
import org.example.order.dto.OrderItemDTO;
import org.example.order.dto.ProductDTO;
import org.example.order.entity.Order;
import org.example.order.entity.OrderItem;
import org.example.order.entity.OrderStatus;
import org.example.order.exception.OrderNotFoundException;
import org.example.order.exception.ProductServiceException;
import org.example.order.repository.OrderRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class OrderService {
    private final OrderRepository orderRepository;
    private final ProductServiceClient productServiceClient;

    public List<OrderDTO> getAllOrders() {
        return orderRepository.findAll()
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public OrderDTO getOrderById(Long id) {
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new OrderNotFoundException("Order not found with id: " + id));
        return convertToDTO(order);
    }

    @Transactional
    @CircuitBreaker(name = "productService", fallbackMethod = "createOrderFallback")
    public OrderDTO createOrder(OrderDTO orderDTO) {
        try {
            // Validate products and reserve stock
            BigDecimal totalAmount = BigDecimal.ZERO;
            for (OrderItemDTO itemDTO : orderDTO.getItems()) {
                ProductDTO product = productServiceClient.getProductById(itemDTO.getProductId());
                itemDTO.setUnitPrice(product.getPrice().doubleValue());
                totalAmount = totalAmount.add(product.getPrice().multiply(BigDecimal.valueOf(itemDTO.getQuantity())));
                productServiceClient.reserveStock(itemDTO.getProductId(), itemDTO.getQuantity());
            }

            // Create order
            Order order = Order.builder()
                    .customerName(orderDTO.getCustomerName())
                    .customerEmail(orderDTO.getCustomerEmail())
                    .totalAmount(totalAmount)
                    .status(OrderStatus.PENDING)
                    .build();

            Order savedOrder = orderRepository.save(order);

            // Create order items
            for (OrderItemDTO itemDTO : orderDTO.getItems()) {
                OrderItem orderItem = OrderItem.builder()
                        .productId(itemDTO.getProductId())
                        .quantity(itemDTO.getQuantity())
                        .unitPrice(itemDTO.getUnitPrice())
                        .order(savedOrder)
                        .build();
                savedOrder.getItems().add(orderItem);
            }

            Order updatedOrder = orderRepository.save(savedOrder);
            return convertToDTO(updatedOrder);
        } catch (Exception ex) {
            throw new ProductServiceException("Failed to create order: " + ex.getMessage(), ex);
        }
    }

    /**
     * Actualiza el estado de una orden.
     *
     * @param id ID de la orden
     * @param status Nuevo estado
     * @return Orden actualizada
     * @throws OrderNotFoundException si la orden no existe
     */
    @Transactional
    public OrderDTO updateOrderStatus(Long id, OrderStatus status) {
        log.info("Updating order {} status to: {}", id, status);
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new OrderNotFoundException("Order not found with id: " + id));
        order.setStatus(status);
        Order updatedOrder = orderRepository.save(order);
        log.info("Order {} status updated successfully", id);
        return convertToDTO(updatedOrder);
    }

    /**
     * Cancela una orden y libera el stock reservado.
     *
     * @param id ID de la orden
     * @throws OrderNotFoundException si la orden no existe
     */
    @Transactional
    public void cancelOrder(Long id) {
        log.info("Cancelling order with id: {}", id);
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new OrderNotFoundException("Order not found with id: " + id));

        // Liberar stock reservado
        log.debug("Releasing stock for {} items", order.getItems().size());
        for (OrderItem item : order.getItems()) {
            try {
                log.debug("Releasing stock for product {}: quantity {}", 
                        item.getProductId(), item.getQuantity());
                productServiceClient.releaseStock(item.getProductId(), item.getQuantity());
            } catch (Exception ex) {
                log.warn("Failed to release stock for product {}, but continuing with cancellation",
                        item.getProductId(), ex);
            }
        }

        order.setStatus(OrderStatus.CANCELLED);
        orderRepository.save(order);
        log.info("Order {} cancelled successfully", id);
    }

    /**
     * Convierte una entidad Order a OrderDTO.
     *
     * @param order Entidad Order
     * @return OrderDTO
     */
    private OrderDTO convertToDTO(Order order) {
        return OrderDTO.builder()
                .id(order.getId())
                .customerName(order.getCustomerName())
                .customerEmail(order.getCustomerEmail())
                .totalAmount(order.getTotalAmount())
                .status(order.getStatus())
                .createdAt(order.getCreatedAt())
                .items(order.getItems() != null ?
                        order.getItems().stream()
                                .map(item -> OrderItemDTO.builder()
                                        .id(item.getId())
                                        .productId(item.getProductId())
                                        .quantity(item.getQuantity())
                                        .unitPrice(item.getUnitPrice())
                                        .build())
                                .collect(Collectors.toList())
                        : List.of())
                .build();
    }

    /**
     * Método fallback cuando Product Service no está disponible.
     *
     * @param orderDTO Datos de la orden
     * @param ex Excepción causante
     * @throws ProductServiceException siempre
     */
    public OrderDTO createOrderFallback(OrderDTO orderDTO, Exception ex) {
        log.error("Fallback triggered for order creation", ex);
        throw new ProductServiceException("Product Service is temporarily unavailable. Please try again later.", ex);
    }
}

