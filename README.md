# Homebrew Tap for Arkime

[Arkime](https://arkime.com) is a full packet capture, indexing, and database system.

## Installation

```bash
brew tap arkime/arkime
brew install arkime/arkime/arkime
```

Arkime is installed as keg-only and won't link into `/opt/homebrew/bin`. The install lives at:

```
/opt/homebrew/opt/arkime/
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
