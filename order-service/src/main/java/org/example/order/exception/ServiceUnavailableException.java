package org.example.order.exception;

/**
 * Excepción lanzada cuando un servicio externo no está disponible.
 * Se usa en fallback de Feign clients cuando no se puede conectar.
 */
public class ServiceUnavailableException extends RuntimeException {

    public ServiceUnavailableException(String message) {
        super(message);
    }

    public ServiceUnavailableException(String message, Throwable cause) {
        super(message, cause);
    }
}

