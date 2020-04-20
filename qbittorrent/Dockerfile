FROM alpine:3

RUN echo "@edge http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories
RUN echo "@edgecommunity http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories
RUN echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
RUN apk add --no-cache qbittorrent-nox@testing qt5-qtbase@edgecommunity icu-libs@edge curl
RUN adduser -h /qb -D qb
USER qb
WORKDIR /qb
COPY --chown=qb:qb ./start.sh /qb
CMD ["/qb/start.sh"]

EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=10s --start-period=20s \
  CMD wget -O- http://localhost:8080 || exit 1