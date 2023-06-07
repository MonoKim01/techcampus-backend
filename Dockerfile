# Stage 1: Build the application
FROM gradle:7.3.1-jdk17 as build

RUN sudo chown newuser /home/gradle/project
USER newuser
WORKDIR /home/gradle/project

COPY . .

# Java 프록시 설정
RUN mkdir -p /root/.gradle 
RUN echo "systemProp.http.proxyHost=krmp-proxy.9rum.cc\nsystemProp.http.proxyPort=3128\nsystemProp.https.proxyHost=krmp-proxy.9rum.cc\nsystemProp.https.proxyPort=3128" > /root/.gradle/gradle.properties

RUN gradle build -x test

# Stage 2: Run the application
FROM eclipse-temurin:17-jre

WORKDIR /opt/techcampus

COPY --from=build /home/gradle/project/build/libs/kakao-0.0.1-SNAPSHOT.jar .

USER nobody

EXPOSE 8080

ENV DATABASE_URL=jdbc:mariadb://localhost:3306/kakao

# Java 프록시 설정
RUN mkdir -p /root/.gradle 
RUN echo "systemProp.http.proxyHost=krmp-proxy.9rum.cc\nsystemProp.http.proxyPort=3128\nsystemProp.https.proxyHost=krmp-proxy.9rum.cc\nsystemProp.https.proxyPort=3128" > /root/.gradle/gradle.properties

CMD ["java", "-jar", "kakao-0.0.1-SNAPSHOT.jar"]
