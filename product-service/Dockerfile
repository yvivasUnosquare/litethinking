FROM eclipse-temurin:21-jdk-alpine AS builder

WORKDIR /workspace

# Copy gradle wrapper and build files from root
COPY gradlew .
COPY gradle gradle
COPY build.gradle .
COPY settings.gradle .
COPY lombok.config .

# Copy all subproject build files
COPY product-service/build.gradle product-service/
COPY order-service/build.gradle order-service/
COPY api-gateway/build.gradle api-gateway/

# Copy product-service source code
COPY product-service/src product-service/src

# Build only the product-service
RUN chmod +x gradlew && ./gradlew :product-service:bootJar -x test

# Runtime stage
FROM eclipse-temurin:21-jre-alpine

# Install wget for healthcheck
RUN apk add --no-cache wget

WORKDIR /app

# Copy the built jar from builder stage
COPY --from=builder /workspace/product-service/build/libs/*.jar app.jar

EXPOSE 8081

ENTRYPOINT ["java", "-jar", "app.jar"]

