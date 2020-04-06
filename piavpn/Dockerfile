FROM alpine:3 AS builder

ARG PIAVPN="https://www.privateinternetaccess.com/openvpn/openvpn.zip"

RUN wget -O /pia.zip $PIAVPN
RUN cd /tmp && unzip /pia.zip

###
FROM alpine:3

LABEL author=sedlund

# Defaults: Override these in your environment on run or in docker-compose.yaml etc...
ENV PIA_AUTH="user:pass"
# Port Forwarding Servers: https://www.privateinternetaccess.com/helpdesk/kb/articles/can-i-use-port-forwarding-without-using-the-pia-client
ENV PIA_SERVER="DE Berlin"

RUN apk add --no-cache openvpn
RUN mkdir /vpn /etc/openvpn/pia

COPY --from=builder /tmp /etc/openvpn/pia
COPY ./start.sh /vpn

WORKDIR /vpn
CMD ["/vpn/start.sh"]

EXPOSE 9047
HEALTHCHECK --interval=300s --timeout=30s --start-period=15s --retries=3 \
  CMD [ 'wget -qO- http://privateinternetaccess.com | grep "You are protected by PIA" && wget -qO- localhost:9047 || exit 1' ]