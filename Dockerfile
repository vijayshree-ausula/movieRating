FROM openjdk:17-jdk-slim

# Create log directories and files
RUN mkdir -p /var/log/myapp \
    && touch /var/log/movie-rating/app.log \
    && touch /var/log/movie-rating/app_access.log

RUN chmod 777 /var/log/movie-rating
# Set permissions (important for non-root user)
RUN chown -R ec2-user:ec2-user /var/log/movie-rating

WORKDIR /app
COPY target/movierating-0.0.1-SNAPSHOT.jar app.jar

# Create a non-root user
RUN useradd -ms /bin/bash ec2-user

# Give the user ownership of the app directory
RUN chown -R ec2-user:ec2-user /app

# Switch to the new user
USER ec2-user

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
