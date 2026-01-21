# Use official OpenJDK 23 image for production
FROM eclipse-temurin:23-jdk AS build
WORKDIR /app

# Copy only what we need for a reproducible Gradle build
COPY gradlew gradlew.bat build.gradle settings.gradle /app/
COPY gradle /app/gradle

# Copy sources
COPY src /app/src

# Build a runnable jar (skip tests in CI image build unless you have DB-independent tests)
RUN chmod +x /app/gradlew && /app/gradlew clean bootJar -x test

FROM eclipse-temurin:23-jre AS runtime
WORKDIR /app

ENV TZ=UTC
ENV JAVA_OPTS=""

COPY --from=build /app/build/libs/*.jar app.jar

EXPOSE 8081

ENTRYPOINT ["java", "-jar", "app.jar"]