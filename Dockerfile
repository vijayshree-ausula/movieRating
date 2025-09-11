FROM openjdk:17-jdk-slim

WORKDIR /app
COPY target/movierating-0.0.1-SNAPSHOT.jar app.jar

# Create a non-root user
RUN useradd -ms /bin/bash appuser

# Give the user ownership of the app directory
RUN chown -R appuser:appuser /app

# Switch to the new user
USER appuser

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
