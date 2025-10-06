# Dockerizing renderapi

This project includes a multi-stage Dockerfile that builds the Spring Boot application using Maven and runs it on a lightweight JRE image.

Build image (from project root):

    docker build -t renderapi:latest .

Run container:

    docker run -p 8080:8080 --rm renderapi:latest

Alternatively, build with Maven locally first (faster iterations):

    mvn -DskipTests package
    docker build -t renderapi:local .

Notes:
- The Dockerfile expects the built jar at target/renderapi-0.0.1-SNAPSHOT.jar. Update the Dockerfile if you change the artifactId or version in `pom.xml`.
- The image exposes port 8080; change if your app uses a different port.
- This workspace doesn't have Docker available in the current environment where I ran the verification steps, so I couldn't run the image here. The Dockerfile builds locally (multi-stage) and was validated by creating the jar with Maven.
