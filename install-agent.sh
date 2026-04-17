#!/bin/sh
# botpilot-agent install script (v3 — GitHub Release binary)
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/sky0926a/botpilot-agent-app/main/install-agent.sh | sh
#
# Env overrides:
#   AGENT_REPO       Default: sky0926a/botpilot-agent-app (public release repo)
#   AGENT_VERSION    Default: latest (e.g., v1.2.3 for a specific version)
#   AGENT_BIN_DIR    Default: /usr/local/bin (falls back to ~/.local/bin if not writable)
#
# Requires: curl or wget. No runtime dependencies (agent is a single compiled binary).
set -eu

AGENT_REPO="${AGENT_REPO:-sky0926a/botpilot-agent-app}"
AGENT_VERSION="${AGENT_VERSION:-latest}"
DEFAULT_BIN_DIR="/usr/local/bin"
FALLBACK_BIN_DIR="${HOME}/.local/bin"

SUPPORTED_TARGETS="bun-darwin-arm64"

say() { printf '%s\n' "$*"; }
die() { printf 'install-agent: %s\n' "$*" >&2; exit 1; }

# ── Detect platform ──────────────────────────────────────────────────

detect_target() {
  uname_os=$(uname -s 2>/dev/null || echo unknown)
  uname_arch=$(uname -m 2>/dev/null || echo unknown)

  case "${uname_os}" in
    Darwin) target_os=darwin ;;
    Linux)  target_os=linux ;;
    *)      die "unsupported OS: ${uname_os} (supported: ${SUPPORTED_TARGETS})" ;;
  esac

  case "${uname_arch}" in
    arm64|aarch64) target_arch=arm64 ;;
    x86_64|amd64)  target_arch=x64 ;;
    *)             die "unsupported arch: ${uname_arch} (supported: ${SUPPORTED_TARGETS})" ;;
  esac

  TARGET="bun-${target_os}-${target_arch}"

  case " ${SUPPORTED_TARGETS} " in
    *" ${TARGET} "*) : ;;
    *) die "detected ${TARGET} but not in supported set (${SUPPORTED_TARGETS})" ;;
  esac
}

# ── Pick downloader ──────────────────────────────────────────────────

pick_downloader() {
  if command -v curl >/dev/null 2>&1; then
    DL_CMD='curl -fsSL'
  elif command -v wget >/dev/null 2>&1; then
    DL_CMD='wget -qO-'
  else
    die "need curl or wget to download the binary"
  fi
}

download_to() {
  # $1 = url, $2 = dest path
  _url=$1
  _dest=$2
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL -o "${_dest}" "${_url}"
  else
    wget -qO "${_dest}" "${_url}"
  fi
}

# ── Resolve release ──────────────────────────────────────────────────

resolve_download_url() {
  asset="botpilot-agent-${TARGET}"
  if [ "${AGENT_VERSION}" = "latest" ]; then
    DOWNLOAD_URL="https://github.com/${AGENT_REPO}/releases/latest/download/${asset}"
  else
    DOWNLOAD_URL="https://github.com/${AGENT_REPO}/releases/download/${AGENT_VERSION}/${asset}"
  fi
}

# ── Pick install dir ─────────────────────────────────────────────────

pick_bin_dir() {
  if [ -n "${AGENT_BIN_DIR:-}" ]; then
    BIN_DIR="${AGENT_BIN_DIR}"
    return
  fi
  if [ -w "${DEFAULT_BIN_DIR}" ] 2>/dev/null; then
    BIN_DIR="${DEFAULT_BIN_DIR}"
  else
    BIN_DIR="${FALLBACK_BIN_DIR}"
  fi
}

# ── Install ──────────────────────────────────────────────────────────

install_binary() {
  mkdir -p "${BIN_DIR}"
  bin_path="${BIN_DIR}/botpilot-agent"
  tmp_path="${bin_path}.download"

  say "Downloading ${TARGET} from ${DOWNLOAD_URL}"
  if ! download_to "${DOWNLOAD_URL}" "${tmp_path}"; then
    rm -f "${tmp_path}"
    die "download failed — verify that ${AGENT_VERSION} release exists at https://github.com/${AGENT_REPO}/releases"
  fi

  if [ ! -s "${tmp_path}" ]; then
    rm -f "${tmp_path}"
    die "downloaded file is empty (${tmp_path})"
  fi

  mv "${tmp_path}" "${bin_path}"
  chmod +x "${bin_path}"

  say "Installed botpilot-agent to ${bin_path}"
  INSTALLED_PATH="${bin_path}"
}

# ── Post-install hints ──────────────────────────────────────────────

print_macos_gatekeeper_hint() {
  [ "${target_os}" = "darwin" ] || return 0
  say ""
  say "⚠ macOS Gatekeeper notice:"
  say "  This binary is not signed or notarized. The first run may be blocked."
  say "  To allow it, run:"
  say "    xattr -d com.apple.quarantine \"${INSTALLED_PATH}\""
  say "  Or right-click the binary in Finder and choose 'Open'."
}

print_path_hint() {
  case ":${PATH}:" in
    *":${BIN_DIR}:"*) return 0 ;;
  esac
  say ""
  say "Add to your shell profile so 'botpilot-agent' is on PATH:"
  say "  export PATH=\"${BIN_DIR}:\$PATH\""
}

# ── Main ─────────────────────────────────────────────────────────────

detect_target
pick_downloader
resolve_download_url
pick_bin_dir
install_binary
print_macos_gatekeeper_hint
print_path_hint

say ""
say "Next: botpilot-agent login <your-dashboard-url>"
