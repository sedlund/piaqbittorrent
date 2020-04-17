#!/bin/ash -x
# shellcheck shell=dash

if ! pgrep qbittorrent-nox >/dev/null; then
    echo y | qbittorrent-nox --profile=/data --webui-port=8080 &
fi

# FIXME: wait for client to come up, as the qB API will respond with empty
# replies should check responses in wait_for_resp
sleep 5

VPNAPI="http://localhost:9047"
QB="http://localhost:8080"
QBLOGIN="${QB}/api/v2/auth/login"
QBUSER="${QBADMIN:-admin}"
QBPASS="${QBPASS:-adminadmin}"

# runs a command / if it doesnt exit clean, try it again for a bit
# FIXME: check response for Ok or Failed
wait_for_resp () {
    SECS=0
    while ! OUT=$(eval "$1"); do
        if [ "${SECS}" -lt $(( 3 * 60 )) ]; then
            echo "$(date) $2 Will retry."
            sleep 3
            SECS=$((SECS + 3))
        else
            echo "$(date) $2 Exiting."
            exit 1
        fi
    done
}

# Get the port to listen on from the VPN API
get_vpn_port () {
    wait_for_resp \
        "curl --silent --retry 3 ${VPNAPI} | cut -d : -f 2 | cut -d \} -f 1" \
        "No response from VPN API" \
        && VPNPORT="${OUT}"
}

# Login to the QB API
qb_login () {
    wait_for_resp \
        "curl --include --retry 3 --header 'Referer: http://localhost:8080' --data username=${QBUSER}\&password=${QBPASS} ${QBLOGIN} | grep set-cookie | cut -d : -f 2 | cut -d \; -f 1" \
        "No respoonse from qBittorrent API" \
        && QBCOOKIE="${OUT}"
}

# Set the port to listen on
qb_set_listen_port () {
    wait_for_resp \
        "curl --silent --include --retry 3 ${QB}/api/v2/app/setPreferences?json=%7B%22listen_port%22:${VPNPORT}%7D --cookie ${QBCOOKIE}" \
        "No response from qBittorrent API"
}

### MAIN

qb_login
qb_set_listen_port

while true; do
    # watch the tunnel / if the vpn container exits this needs to restart to reattach to its network
    if ip link show tun0 >/dev/null; then
        get_vpn_port
        sleep 30
    else
        echo "VPN tunnel is down, stopping container to wait for it to be restarted."
        sleep 3
        exit 1
    fi
done
