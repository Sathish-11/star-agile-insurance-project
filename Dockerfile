# === stage 1: build the app with maven ===
FROM maven:3.8.8-openjdk-17 AS builder
WORKDIR /build

# Cache maven deps (optional)
COPY pom.xml .
RUN mvn -B -DskipTests dependency:go-offline

# Copy sources and build
COPY src ./src
RUN mvn -B clean package -DskipTests

# === stage 2: tomcat runtime with WAR copied into webapps ===
FROM tomcat:9.0-jdk17
# Remove default apps to keep container slim
RUN rm -rf /usr/local/tomcat/webapps/*
# Copy the built WAR from builder stage
COPY --from=builder /build/target/*.war /usr/local/tomcat/webapps/ROOT.war

# Expose Tomcat port
EXPOSE 8083

# Start Tomcat (default CMD in base image is fine)
CMD ["catalina.sh", "run"]

