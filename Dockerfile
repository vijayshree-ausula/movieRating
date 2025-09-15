FROM openjdk:17-jdk-slim

WORKDIR /app
COPY target/movierating-0.0.1-SNAPSHOT.jar app.jar

# Create a non-root user
RUN useradd -ms /bin/bash ec2-user

# Give the user ownership of the app directory
RUN chown -R ec2-user:ec2-user /app

# Switch to the new user
USER ec2-user

# Create log directories and files
RUN mkdir -p /app/logs/movie-rating \
    && touch /app/logs/movie-rating/app.log \
    && touch /app/logs/movie-rating/app_access.log

RUN chmod 777 /app/logs/movie-rating/app_access.log
# Set permissions (important for non-root user)
RUN chown -R ec2-user:ec2-user /app/logs/movie-rating/app_access.log

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
