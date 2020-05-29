FROM busybox:1-uclibc AS builder

ARG RELEASE

WORKDIR /webui
RUN wget -O webui.zip $RELEASE
RUN unzip webui.zip

###
# This image only builds on building hosts architecture, so it will not run on
# other arch's.  It's using a trick in that docker will create a container from
# an image when called to start an executable even though it may not be for it's
# architecture.  This container will show Exited on it's native arch (amd64),
# and Exited 1 (failed) on others after docker-compose starts it.  This is ok.
#
# With that we can mount the filesystem from this container in the main
# container.  This busybox image has a default Cmd set (sh), so we don't have to
# specify it in the docker-compose file.
FROM busybox:1-uclibc

WORKDIR /webui
COPY --chown=1000:1000 --from=builder /webui/dist .
