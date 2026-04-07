#!/usr/bin/env zsh

set -euo pipefail

brew install derailed/k9s/k9s

K9S_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/k9s"
K9S_CONFIG_FILE="${K9S_CONFIG_DIR}/config.yaml"
K9S_SKIN_FILE="${K9S_CONFIG_DIR}/transparent.yaml"
K9S_SKIN_URL="https://raw.githubusercontent.com/derailed/k9s/refs/heads/master/skins/transparent.yaml"

mkdir -p "${K9S_CONFIG_DIR}"

if [ ! -f "${K9S_CONFIG_FILE}" ]; then
  cat > "${K9S_CONFIG_FILE}" <<'EOF'
k9s:
  ui:
    skin: transparent
EOF
fi

if command -v curl >/dev/null 2>&1; then
  curl -fsSL "${K9S_SKIN_URL}" -o "${K9S_SKIN_FILE}"
elif command -v wget >/dev/null 2>&1; then
  wget -qO "${K9S_SKIN_FILE}" "${K9S_SKIN_URL}"
else
  echo "Neither curl nor wget is installed; cannot download k9s transparent skin." >&2
  exit 1
fi

if [ ! -s "${K9S_SKIN_FILE}" ]; then
  echo "Failed to download k9s transparent skin to ${K9S_SKIN_FILE}." >&2
  exit 1
fi
