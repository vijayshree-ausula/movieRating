FROM openjdk:17-jdk-slim

WORKDIR /app
COPY target/movierating-0.0.1-SNAPSHOT.jar app.jar

# Create a non-root user
RUN useradd -ms /bin/bash ec2-user


# Give the user ownership of the app directory
RUN chown -R ec2-user:ec2-user /app

#Make log directory
RUN mkdir -p /var/log/tomcat \
    && chown -R ec2-user:ec2-user /var/log/tomcat

# Switch to the new user
USER ec2-user
#USER root


#Redirect logs to container stdout
RUN ln -sf /dev/stdout /var/log/tomcat/access.log

EXPOSE 8080
#ENTRYPOINT ["sh", "-c", "java -jar app.jar | tee -a /var/log/tomcat/access.log"]
ENTRYPOINT ["sh", "-c", "java -jar app.jar"]
