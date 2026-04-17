# botpilot-agent-app

Public release channel for [`botpilot-agent`](https://github.com/sky0926a/botpilot-agent) — the BotPilot client that connects a computer to BotPilot Discord / control-plane sessions.

This repository hosts binary releases and the installer. **Agent source code lives in the private `botpilot-agent` repo.**

## Install

One command, no dependencies:

```sh
curl -fsSL https://raw.githubusercontent.com/sky0926a/botpilot-agent-app/main/install-agent.sh | sh
```

The installer:

1. Detects your OS and CPU architecture (supports macOS arm64/x64, Linux arm64/x64).
2. Downloads the matching single-file executable from the latest GitHub Release.
3. Installs it to `/usr/local/bin/botpilot-agent`, falling back to `~/.local/bin/` if `/usr/local/bin` is not writable.
4. On macOS, prints an `xattr -d com.apple.quarantine` hint (binaries are unsigned today).

### Pin a specific version

```sh
AGENT_VERSION=v1.2.3 curl -fsSL https://raw.githubusercontent.com/sky0926a/botpilot-agent-app/main/install-agent.sh | sh
```

### Choose install directory

```sh
AGENT_BIN_DIR="$HOME/bin" curl -fsSL https://raw.githubusercontent.com/sky0926a/botpilot-agent-app/main/install-agent.sh | sh
```

## Supported platforms

| Target                | Binary asset                            |
| --------------------- | --------------------------------------- |
| macOS Apple Silicon   | `botpilot-agent-bun-darwin-arm64`       |
| macOS Intel           | `botpilot-agent-bun-darwin-x64`         |
| Linux x86_64          | `botpilot-agent-bun-linux-x64`          |
| Linux ARM64           | `botpilot-agent-bun-linux-arm64`        |

## After install

```sh
botpilot-agent login <your-dashboard-url>
botpilot-agent start
```

## Release process

Releases here are cut automatically by CI in the private source repo. When a
`v*` tag is pushed to `botpilot-agent`, the build matrix compiles four binaries
with `bun build --compile` and uploads them as a GitHub Release on this repo.
This repo's `main` only holds the installer script; all versioned artifacts
live under [Releases](https://github.com/sky0926a/botpilot-agent-app/releases).
