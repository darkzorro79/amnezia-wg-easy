# AmnewziaWG Easy

You have found the easiest way to install & manage WireGuard on any Linux host!

<p align="center">
  <img src="./assets/screenshot.png" width="802" />
</p>

## Features

* All-in-one: AmneziaWG + Web UI.
* Easy installation, simple to use.
* List, create, edit, delete, enable & disable clients.
* Show a client's QR code.
* Download a client's configuration file.
* Statistics for which clients are connected.
* Tx/Rx charts for each connected client.
* Gravatar support or random avatars.
* Automatic Light / Dark Mode
* Multilanguage Support
* Traffic Stats (default off)
* One Time Links (default off)
* Client Expiry (default off)
* Prometheus metrics support

## Requirements

* A host with Docker installed.

## Installation

### 1. Install Docker

If you haven't installed Docker yet, install it by running:

```bash
curl -sSL https://get.docker.com | sh
sudo usermod -aG docker $(whoami)
exit
```

And log in again.

### 2. Quick Setup with Docker Compose (Recommended)

For the easiest setup experience, use the automated configuration script:

```bash
# Clone or download this repository
git clone https://github.com/w0rng/amnezia-wg-easy.git
cd amnezia-wg-easy

# Run the setup script
./setup-env.sh
```

The setup script will:
- ✅ Automatically generate a secure bcrypt password hash
- ✅ Create a properly configured `.env` file
- ✅ Handle special characters correctly for docker-compose
- ✅ Configure AmneziaWG obfuscation parameters
- ✅ Add `.env` to `.gitignore` for security

After the setup is complete, start the service:

```bash
docker-compose up -d
```

> 💡 The setup script will ask for your server IP and admin password, then generate all necessary configuration automatically.

### 3. Manual Docker Run

To manually install & run amnezia-wg-easy without docker-compose, run:

```
  docker run -d \
  --name=amnezia-wg-easy \
  -e LANG=en \
  -e WG_HOST=<🚨YOUR_SERVER_IP> \
  -e PASSWORD_HASH=<🚨YOUR_ADMIN_PASSWORD_HASH> \
  -e PORT=51821 \
  -e WG_PORT=51820 \
  -v ~/.amnezia-wg-easy:/etc/wireguard \
  -p 51820:51820/udp \
  -p 51821:51821/tcp \
  --cap-add=NET_ADMIN \
  --cap-add=SYS_MODULE \
  --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
  --sysctl="net.ipv4.ip_forward=1" \
  --device=/dev/net/tun:/dev/net/tun \
  --restart unless-stopped \
  ghcr.io/w0rng/amnezia-wg-easy
```

> 💡 Replace `YOUR_SERVER_IP` with your WAN IP, or a Dynamic DNS hostname.
>
> 💡 Replace `YOUR_ADMIN_PASSWORD_HASH` with a bcrypt password hash to log in on the Web UI.
> See [How_to_generate_an_bcrypt_hash.md](./How_to_generate_an_bcrypt_hash.md) for know how generate the hash.

The Web UI will now be available on `http://YOUR_SERVER_IP:51821` (or the port you configured).

The Prometheus metrics will now be available on `http://YOUR_SERVER_IP:51821/metrics`. Grafana dashboard [21733](https://grafana.com/grafana/dashboards/21733-wireguard/)

> 💡 When using docker-compose, your configuration files will be saved in the `etc_wireguard` volume.
> When using manual docker run, your configuration files will be saved in `~/.amnezia-wg-easy`

## Options

These options can be configured by setting environment variables using `-e KEY="VALUE"` in the `docker run` command.

| Env                           | Default           | Example                        | Description                                                                                                                                                                                                              |
|-------------------------------|-------------------|--------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `PORT`                        | `51821`           | `6789`                         | TCP port for Web UI.                                                                                                                                                                                                     |
| `WEBUI_HOST`                  | `0.0.0.0`         | `localhost`                    | IP address web UI binds to.                                                                                                                                                                                              |
| `PASSWORD_HASH`               | -                 | `$2y$05$Ci...`                 | When set, requires a password when logging in to the Web UI. See [How to generate an bcrypt hash.md]("https://github.com/wg-easy/wg-easy/blob/master/How_to_generate_an_bcrypt_hash.md") for know how generate the hash. |
| `WG_HOST`                     | -                 | `vpn.myserver.com`             | The public hostname of your VPN server.                                                                                                                                                                                  |
| `WG_DEVICE`                   | `eth0`            | `ens6f0`                       | Ethernet device the wireguard traffic should be forwarded through.                                                                                                                                                       |
| `WG_PORT`                     | `51820`           | `12345`                        | The public UDP port of your VPN server. WireGuard will listen on that (othwise default) inside the Docker container.                                                                                                     |
| `WG_CONFIG_PORT`              | `51820`           | `12345`                        | The UDP port used on [Home Assistant Plugin](https://github.com/adriy-be/homeassistant-addons-jdeath/tree/main/wgeasy)                                                                                                   |
| `WG_MTU`                      | `null`            | `1420`                         | The MTU the clients will use. Server uses default WG MTU.                                                                                                                                                                |
| `WG_PERSISTENT_KEEPALIVE`     | `0`               | `25`                           | Value in seconds to keep the "connection" open. If this value is 0, then connections won't be kept alive.                                                                                                                |
| `WG_DEFAULT_ADDRESS`          | `10.8.0.x`        | `10.6.0.x`                     | Clients IP address range.                                                                                                                                                                                                |
| `WG_DEFAULT_DNS`              | `1.1.1.1`         | `8.8.8.8, 8.8.4.4`             | DNS server clients will use. If set to blank value, clients will not use any DNS.                                                                                                                                        |
| `WG_ALLOWED_IPS`              | `0.0.0.0/0, ::/0` | `192.168.15.0/24, 10.0.1.0/24` | Allowed IPs clients will use.                                                                                                                                                                                            |
| `WG_PRE_UP`                   | `...`             | -                              | See [config.js](https://github.com/wg-easy/wg-easy/blob/master/src/config.js#L19) for the default value.                                                                                                                 |
| `WG_POST_UP`                  | `...`             | `iptables ...`                 | See [config.js](https://github.com/wg-easy/wg-easy/blob/master/src/config.js#L20) for the default value.                                                                                                                 |
| `WG_PRE_DOWN`                 | `...`             | -                              | See [config.js](https://github.com/wg-easy/wg-easy/blob/master/src/config.js#L27) for the default value.                                                                                                                 |
| `WG_POST_DOWN`                | `...`             | `iptables ...`                 | See [config.js](https://github.com/wg-easy/wg-easy/blob/master/src/config.js#L28) for the default value.                                                                                                                 |
| `WG_ENABLE_EXPIRES_TIME`      | `false`           | `true`                         | Enable expire time for clients                                                                                                                                                                                           |
| `LANG`                        | `en`              | `de`                           | Web UI language (Supports: en, ua, ru, tr, no, pl, fr, de, ca, es, ko, vi, nl, is, pt, chs, cht, it, th, hi).                                                                                                            |
| `UI_TRAFFIC_STATS`            | `false`           | `true`                         | Enable detailed RX / TX client stats in Web UI                                                                                                                                                                           |
| `UI_CHART_TYPE`               | `0`               | `1`                            | UI_CHART_TYPE=0 # Charts disabled, UI_CHART_TYPE=1 # Line chart, UI_CHART_TYPE=2 # Area chart, UI_CHART_TYPE=3 # Bar chart                                                                                               |
| `DICEBEAR_TYPE`               | `false`           | `bottts`                       | see [dicebear types](https://www.dicebear.com/styles/)                                                                                                                                                                   |
| `USE_GRAVATAR`                | `false`           | `true`                         | Use or not GRAVATAR service                                                                                                                                                                                              |
| `WG_ENABLE_ONE_TIME_LINKS`    | `false`           | `true`                         | Enable display and generation of short one time download links (expire after 5 minutes)                                                                                                                                  |
| `MAX_AGE`                     | `0`               | `1440`                         | The maximum age of Web UI sessions in minutes. `0` means that the session will exist until the browser is closed.                                                                                                        |
| `UI_ENABLE_SORT_CLIENTS`      | `false`           | `true`                         | Enable UI sort clients by name                                                                                                                                                                                           |
| `ENABLE_PROMETHEUS_METRICS`   | `false`           | `true`                         | Enable Prometheus metrics `http://0.0.0.0:51821/metrics` and `http://0.0.0.0:51821/metrics/json`                                                                                                                         |
| `PROMETHEUS_METRICS_PASSWORD` | -                 | `$2y$05$Ci...`                 | If set, Basic Auth is required when requesting metrics. See [How to generate an bcrypt hash.md]("https://github.com/wg-easy/wg-easy/blob/master/How_to_generate_an_bcrypt_hash.md") for know how generate the hash.      |
| `JC`                          | `random`          | `5`                            | Junk packet count — number of packets with random data that are sent before the start of the session.                                                                                                                    |
| `JMIN`                        | `50`              | `25`                           | Junk packet minimum size — minimum packet size for Junk packet. That is, all randomly generated packets will have a size no smaller than Jmin.                                                                           |
| `JMAX`                        | `1000`            | `250`                          | Junk packet maximum size — maximum size for Junk packets.                                                                                                                                                                |
| `S1`                          | `random`          | `75`                           | Init packet junk size — the size of random data that will be added to the init packet, the size of which is initially fixed.                                                                                             |
| `S2`                          | `random`          | `75`                           | Response packet junk size — the size of random data that will be added to the response packet, the size of which is initially fixed.                                                                                     |
| `H1`                          | `random`          | `1234567891`                   | Init packet magic header — the header of the first byte of the handshake. Must be < uint_max.                                                                                                                            |
| `H2`                          | `random`          | `1234567892`                   | Response packet magic header — header of the first byte of the handshake response. Must be < uint_max.                                                                                                                   |
| `H3`                          | `random`          | `1234567893`                   | Underload packet magic header — UnderLoad packet header. Must be < uint_max.                                                                                                                                             |
| `H4`                          | `random`          | `1234567894`                   | Transport packet magic header — header of the packet of the data packet. Must be < uint_max.                                                                                                                             |

> If you change `WG_PORT`, make sure to also change the exposed port.

## Updating

### Docker Compose Method

To update to the latest version using docker-compose:

```bash
docker-compose down
docker-compose pull
docker-compose up -d
```

### Manual Docker Method

To update to the latest version using manual docker commands:

```bash
docker stop amnezia-wg-easy
docker rm amnezia-wg-easy
docker pull ghcr.io/w0rng/amnezia-wg-easy
```

And then run the `docker run -d \ ...` command above again.

## Additional Setup Files

This repository includes additional setup files to make configuration easier:

### 🚀 `setup-env.sh`
An interactive bash script that automatically configures your `.env` file:
- Generates secure bcrypt password hashes
- Handles special characters correctly for docker-compose 
- Configures all AmneziaWG obfuscation parameters with proper numeric values
- Adds security measures (`.env` to `.gitignore`)

### 🔧 `fix-env.sh`
A repair script for existing `.env` files with configuration issues:
- Automatically fixes "random" values that cause parsing errors
- Creates backup before making changes
- Generates proper numeric values for AmneziaWG parameters
- Safe to run multiple times

### 📖 `SETUP_GUIDE.md`
Comprehensive guide covering:
- Quick setup instructions
- Manual configuration options
- Security best practices
- Troubleshooting tips

### 🐳 `docker-compose.yml`
Production-ready Docker Compose configuration with:
- Environment variable support
- Named volumes for data persistence
- Proper security capabilities
- Network configuration

## Thanks

Based on [wg-easy](https://github.com/wg-easy/wg-easy) by Emile Nijssen.  
Use integrations with AmneziaWg from [amnezia-wg-easy](https://github.com/spcfox/amnezia-wg-easy) by Viktor Yudov.
