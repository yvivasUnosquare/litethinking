package org.example.order.service;

import org.example.order.client.ProductServiceClient;
import org.example.order.dto.OrderDTO;
import org.example.order.dto.OrderItemDTO;
import org.example.order.dto.ProductDTO;
import org.example.order.entity.Order;
import org.example.order.entity.OrderStatus;
import org.example.order.exception.OrderNotFoundException;
import org.example.order.repository.OrderRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class OrderServiceTest {
    @Mock
    private OrderRepository orderRepository;

    @Mock
    private ProductServiceClient productServiceClient;

    @InjectMocks
    private OrderService orderService;

    private Order order;
    private OrderDTO orderDTO;
    private ProductDTO productDTO;

    @BeforeEach
    void setUp() {
        productDTO = ProductDTO.builder()
                .id(1L)
                .name("Test Product")
                .category("Electronics")
                .price(new java.math.BigDecimal("99.99"))
                .stock(10)
                .build();

        order = Order.builder()
                .id(1L)
                .customerName("John Doe")
                .customerEmail("john@example.com")
                .totalAmount(new java.math.BigDecimal("199.98"))
                .status(OrderStatus.PENDING)
                .items(new ArrayList<>())
                .build();

        OrderItemDTO itemDTO = OrderItemDTO.builder()
                .productId(1L)
                .quantity(2)
                .unitPrice(99.99)
                .build();

        orderDTO = OrderDTO.builder()
                .customerName("John Doe")
                .customerEmail("john@example.com")
                .items(List.of(itemDTO))
                .build();
    }

    @Test
    void testGetAllOrders() {
        List<Order> orders = new ArrayList<>();
        orders.add(order);
        when(orderRepository.findAll()).thenReturn(orders);

        List<OrderDTO> result = orderService.getAllOrders();

        assertNotNull(result);
        assertEquals(1, result.size());
        verify(orderRepository, times(1)).findAll();
    }

    @Test
    void testGetOrderById_Success() {
        when(orderRepository.findById(1L)).thenReturn(Optional.of(order));

        OrderDTO result = orderService.getOrderById(1L);

        assertNotNull(result);
        assertEquals(OrderStatus.PENDING, result.getStatus());
        verify(orderRepository, times(1)).findById(1L);
    }

    @Test
    void testGetOrderById_NotFound() {
        when(orderRepository.findById(999L)).thenReturn(Optional.empty());

        assertThrows(OrderNotFoundException.class, () -> orderService.getOrderById(999L));
        verify(orderRepository, times(1)).findById(999L);
    }

    @Test
    void testCreateOrder_Success() {
        when(productServiceClient.getProductById(1L)).thenReturn(productDTO);
        when(orderRepository.save(any(Order.class))).thenReturn(order);

        OrderDTO result = orderService.createOrder(orderDTO);

        assertNotNull(result);
        verify(productServiceClient, times(1)).getProductById(1L);
        verify(productServiceClient, times(1)).reserveStock(1L, 2);
    }

    @Test
    void testUpdateOrderStatus() {
        when(orderRepository.findById(1L)).thenReturn(Optional.of(order));
        when(orderRepository.save(any(Order.class))).thenReturn(order);

        OrderDTO result = orderService.updateOrderStatus(1L, OrderStatus.CONFIRMED);

        assertNotNull(result);
        verify(orderRepository, times(1)).findById(1L);
        verify(orderRepository, times(1)).save(any(Order.class));
    }

    @Test
    void testCancelOrder() {
        when(orderRepository.findById(1L)).thenReturn(Optional.of(order));
        when(orderRepository.save(any(Order.class))).thenReturn(order);

        orderService.cancelOrder(1L);

        verify(orderRepository, times(1)).findById(1L);
        verify(orderRepository, times(1)).save(any(Order.class));
    }
}

