# === stage 1: build the app with Maven ===
FROM maven:3.8.3-openjdk-17 AS builder
WORKDIR /build

# Cache Maven dependencies
COPY pom.xml .
RUN mvn -B -DskipTests dependency:go-offline

# Copy source code and build
COPY src ./src
RUN mvn -B clean package -DskipTests

# === stage 2: runtime ===
FROM openjdk:17-jdk-slim
WORKDIR /app

# Copy the built JAR from the builder stage
COPY --from=builder /build/target/insure-me-1.0.jar app.jar

# Expose application port (Spring Boot default)
EXPOSE 8083

# Run the JAR
ENTRYPOINT ["java", "-jar", "app.jar"]
