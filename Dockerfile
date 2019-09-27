FROM openjdk:8-jre-alpine

COPY entrypoint.sh /entrypoint.sh

RUN apk add libc6-compat bash nodejs

ENTRYPOINT ["/entrypoint.sh"]
