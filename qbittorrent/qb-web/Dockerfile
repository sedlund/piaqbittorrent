FROM busybox:1-uclibc AS builder

ARG RELEASE

WORKDIR /webui
RUN wget -O webui.zip $RELEASE
RUN unzip webui.zip

###
FROM busybox:1-uclibc

WORKDIR /webui
COPY --chown=1000:1000 --from=builder /webui/dist .