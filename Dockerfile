FROM alpine:3.16

ADD spring-starter.sh /spring-starter.sh
RUN apk update && apk add dialog curl jq && rm -rf /var/cache/apk/*

ENTRYPOINT ["sh", "/spring-starter.sh"]
