FROM alpine:3.16

ADD spring-starter.sh /spring-starter.sh
RUN apk add --no-cache dialog curl jq

ENTRYPOINT ["sh", "/spring-starter.sh"]
