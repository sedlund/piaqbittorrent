# Private Internet Access VPN and qBittorrent with WebUI and RSS Downloader

[![Docker Automated build](https://img.shields.io/docker/automated/sedlund/qbittorrent.svg)](https://hub.docker.com/r/sedlund/qbittorrent/)
[![Docker Pulls](https://img.shields.io/docker/pulls/sedlund/qbittorrent.svg)](https://hub.docker.com/r/sedlund/qbittorrent/)
[![Join the chat at https://gitter.im/piaqbittorrent/Lobby](https://badges.gitter.im/piaqbittorrent/Lobby.svg)](https://gitter.im/piaqbittorrent/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

## What

[qBittorrent](https://github.com/qbittorrent/qBittorrent) with [QB-Web](https://github.com/CzBiX/qb-web) interface for setting up RSS downloading and OpenVPN connecting to [Private Internet Access](https://www.privateinternetaccess.com/pages/buy-vpn/traveltech) with port forwarding.

Multi-Architecture images in the Docker registry for amd64, arm64, armv7 and armv6

## Why

* qBittorrent instead of Transmission?
  * Tranmission does not have asynchronus disk IO.  Single threaded IO when allocating or moving torrents makes the UI inaccessable and can lock up a whole system until it completes.  qBittorrent does not have this problem.
  * Transmission does not include an RSS auto downloader.  qBittorrent has an easy to use one that does the job.
* Only Private Internet Access VPN?
  * Containers should be purpose built for simplicity.
  * The architecture makes it easy to add any other provider.
  * Private Internet Access supports port forwarding required for torrenting.  Very few support this, without it your speeds will be slow.
* Separate containers?
  * This architecture makes it easy to swap torrent clients, VPN providers and plug in more functionality with other containers by simply attaching to the VPN container network.

## How

* Edit the `docker-compose.yml`
* Change PIA_AUTH to be your Username:Password
* Change PIA_SERVER to your closest port forwarding enabled VPN server.
* Add your your local networks to LOCAL_NETS (space separated) to add to the routing table so  you can access the WebUI
* Add the local path that you want qBittorrent to use to store config and torrents in the volumes section of the qb service.
* The default WebUI login is admin / adminadmin .  Once you login change the password then update QBPASS in the compose file, then have docker-compose restart the container to make sure all is working as expected.
* To use the optional alternative WebUI for qBittorrent go into the qBittorrent settings in the WebUI tab and put /qb/qb-web in the path field and check the `Use alternative WebUI` box.  Once you hit save you it will bring you to the other WebUI where you can setup your RSS feeds.  You can switch back and forth between the UI's as needed.

Now run `docker-compose up -d`

## Help me help you

If you like this or want help, send me some shekles!  If you want a feature, lets discuss it and you can send me money.

Make a one time or recuring donation through PayPal.

[![Donate with PayPal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=ZZJZTUFQBLNBJ&source=url)

Sign up for [Private Internet Access](https://www.privateinternetaccess.com/pages/buy-vpn/traveltech) through my link.

Crypto

* BTC: `1J55ZLCfLEB8kAaBvKtf3dr1aUVp7BxgLC`
* BCH: `qzclw394kzprt8uzlnyerzdm24mynhd75vsxy4slwg`
* Stellar: `GBG6TLIMYOXMJ6GOQT2M5N5YYWXQX2AQREDVLXFI56G4ZTASPUJ6N3IL`
* Keybase: `bumperboat*keybase.io`
