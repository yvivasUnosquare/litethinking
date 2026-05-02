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

# Copy order-service source code
COPY order-service/src order-service/src

# Build only the order-service
RUN chmod +x gradlew && ./gradlew :order-service:bootJar -x test

# Runtime stage
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Copy the built jar from builder stage
COPY --from=builder /workspace/order-service/build/libs/*.jar app.jar

EXPOSE 8082

ENTRYPOINT ["java", "-jar", "app.jar"]

