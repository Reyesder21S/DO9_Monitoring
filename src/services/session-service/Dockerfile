FROM maven:3.9.6-eclipse-temurin-17 AS builder

WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn package -DskipTests -B

FROM eclipse-temurin:17-jre-alpine

RUN apk add --no-cache curl bash && \
    addgroup -S appuser && adduser -S appuser -G appuser
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
COPY wait-for-it.sh .
RUN chmod +x wait-for-it.sh && chown -R appuser:appuser /app

USER appuser

CMD ["./wait-for-it.sh", "-t", "60", "postgres:5432", "--", \
     "java", "-jar", "app.jar"]
HEALTHCHECK --interval=30s --timeout=15s --retries=5 --start-period=90s \
  CMD curl -f http://localhost:8081/ || exit 1

EXPOSE 8081