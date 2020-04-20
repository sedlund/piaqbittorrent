#!/bin/ash -x
# shellcheck shell=dash

AUTHFILE=/dev/shm/vpnauth.conf
OVPN=/dev/shm/pia.ovpn

# Wait for openvpn to create /dev/net/tun0
wait_for_tun_up () {
    tun_up="false"

    while [ "${tun_up}" = "false" ]; do
        echo "$(date) Waiting for tunnel device to come up"
        if ip link show tun0 2>/dev/null | grep UP >/dev/null; then
            echo "$(date) VPN tunnel is up"
            tun_up="true"
        else
            sleep 3
        fi
    done
}

# Request a port forward from the PIA port forward server
get_port_forward () {
    echo "$(date) Loading port forward assignment information..."
    CID=$(head -n 100 /dev/urandom | sha256sum | tr -d " -")
    SECS=0
    while ! JSON=$(wget -qO- "http://209.222.18.222:2000/?client_id=${CID}" 2>/dev/null); do
        # official gui client tries for 3 minutes to get response then fails
        if [ ${SECS} -lt $(( 3 * 60 )) ]; then
            echo "$(date) No response from port forward server... will try again."
            sleep 3
            SECS=$((SECS + 3))
        else
            echo "$(date) Timeout requesting port from PIA server"
            exit 1
        fi
    done
}

# Add local networks to routing table
# If you cant access the WebUI make sure your local network
# is specified in LOCAL_NET environment variable
add_local_route () {
    GW=$(ip route show to default | awk '{print $3}')
    if [ -n "${LOCAL_NET-}" ]; then
        # shellcheck disable=SC2169 # busybox ash supports string replacement
        for net in ${LOCAL_NET//,/ }; do
            echo "adding route to local network ${net} via ${GW} dev eth0"
            ip route add "${net}" via "${GW}" dev eth0
        done
    fi
}

# Tell requesting clients what port we were given
serve_port () {
    SERVE_PORT=9047
    echo "Serving requests for PIA portforward on port ${SERVE_PORT}"
    # shellcheck disable=SC2169 # busybox ash supports 'echo -e'
    while true; do echo -e "HTTP/1.1 200 OK\n\n ${JSON}" | nc -l -p ${SERVE_PORT}; done
}

echo "${PIA_AUTH}" | sed 's#:#\n#g' > ${AUTHFILE}
chmod 400 ${AUTHFILE}
sed "s#auth-user-pass#auth-user-pass ${AUTHFILE}#" \
    "/etc/openvpn/pia/${PIA_SERVER}.ovpn" > ${OVPN}

# Make tun device for OpenVPN
mkdir -p /dev/net \
    && mknod /dev/net/tun c 10 200 \
    && chmod 0666 /dev/net/tun

# FIXME: this should be wrapped in a health check
openvpn --config ${OVPN} &

wait_for_tun_up
get_port_forward
add_local_route
serve_port
