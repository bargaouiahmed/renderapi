# Multi-stage Dockerfile for building and running the Spring Boot app
# Build stage: use Eclipse Temurin JDK 21 with Maven
FROM eclipse-temurin:21-jdk AS build
WORKDIR /workspace

# Install Maven
RUN apt-get update && \
    apt-get install -y maven && \
    rm -rf /var/lib/apt/lists/*

# Copy only the files needed for dependency resolution first for better caching
COPY pom.xml .
COPY src ./src

# Build the application and skip tests for faster image builds by default
RUN mvn -B -DskipTests package

# Runtime stage: use a lightweight JRE image
FROM eclipse-temurin:21-jre AS runtime

ARG APP_USER=appuser
WORKDIR /app

# Install curl for HEALTHCHECK and remove apt lists to reduce image size
RUN apt-get update \
		&& apt-get install -y --no-install-recommends curl \
		&& rm -rf /var/lib/apt/lists/*

# Create a non-root user and group to run the app
RUN groupadd -r ${APP_USER} && useradd -r -g ${APP_USER} ${APP_USER}

# Copy the jar from the build stage. Adjust filename if you change version in pom.xml
COPY --from=build /workspace/target/renderapi-0.0.1-SNAPSHOT.jar /app/app.jar
RUN chown ${APP_USER}:${APP_USER} /app/app.jar

EXPOSE 8080

# Switch to non-root user
USER ${APP_USER}

ENTRYPOINT ["java", "-jar", "/app/app.jar"]

# Lightweight healthcheck that hits the simple test endpoint
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
	CMD curl -f http://localhost:8080/test/hello || exit 1
