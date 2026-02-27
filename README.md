# Homebrew Tap for Arkime

[Arkime](https://arkime.com) is a full packet capture, indexing, and database system.

## Installation

```bash
brew tap arkime/arkime
brew install arkime/arkime/arkime
```

Arkime is installed as keg-only. Use the service formulas below to run Arkime components.

## Initial Setup

If you've never initialized the Arkime database before, run:

```bash
/opt/homebrew/opt/arkime/db/db.pl http://localhost:9200 init
```

Next, update the [configuration files](#configuration) — at minimum, set `ARKIME_INTERFACE` and `ARKIME_PASSWORD` in `config.ini`.

To add your first admin user:

```bash
/opt/homebrew/opt/arkime/bin/arkime_add_user.sh admin admin admin --admin
```

## Services

Each Arkime component has its own service formula that you can install and enable independently:

| Formula | Description | Install |
|---------|-------------|---------|
| `arkime-capture` | Packet capture daemon | `brew install arkime/arkime/arkime-capture` |
| `arkime-viewer` | Web UI and API server | `brew install arkime/arkime/arkime-viewer` |
| `arkime-wise` | WISE data enrichment service | `brew install arkime/arkime/arkime-wise` |
| `arkime-cont3xt` | Threat intelligence tool | `brew install arkime/arkime/arkime-cont3xt` |
| `arkime-parliament` | Cluster management UI | `brew install arkime/arkime/arkime-parliament` |

### Starting and stopping services

```bash
# Start a service (capture requires sudo for packet access)
sudo brew services start arkime/arkime/arkime-capture
brew services start arkime/arkime/arkime-viewer

# Stop a service
sudo brew services stop arkime/arkime/arkime-capture
brew services stop arkime/arkime/arkime-viewer

# List running services
brew services list
```

## Configuration

> **⚠️ Important:** You **must** update `ARKIME_INTERFACE` and `ARKIME_PASSWORD` in the configuration files before using Arkime. Edit `/opt/homebrew/etc/arkime/config.ini` and replace the placeholder values with your network interface and desired password.

Config files live in `/opt/homebrew/etc/arkime/`:

| Service | Config File |
|---------|-------------|
| capture | `config.ini` |
| viewer | `config.ini` |
| wise | `wise.ini` |
| cont3xt | `cont3xt.ini` |
| parliament | `parliament.ini` |

Logs are written to `/opt/homebrew/var/log/arkime/`.

## Updating

When a new version is released, maintainers can bump all formulas at once:

```bash
./bump.sh 6.1.0
git commit -am "Bump to v6.1.0" && git push
```

Then users upgrade with:

```bash
brew update
brew upgrade arkime/arkime/arkime
```
