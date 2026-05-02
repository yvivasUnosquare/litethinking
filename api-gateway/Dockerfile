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

# Copy api-gateway source code
COPY api-gateway/src api-gateway/src

# Build only the api-gateway
RUN chmod +x gradlew && ./gradlew :api-gateway:bootJar -x test

# Runtime stage
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Copy the built jar from builder stage
COPY --from=builder /workspace/api-gateway/build/libs/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]

