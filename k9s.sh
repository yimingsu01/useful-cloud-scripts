#!/usr/bin/env zsh

brew install derailed/k9s/k9s

K9S_CONFIG_DIR="/users/yimingsu/.config/k9s"
K9S_CONFIG_FILE="${K9S_CONFIG_DIR}/config.yaml"
K9S_SKIN_FILE="${K9S_CONFIG_DIR}/transparent.yaml"
K9S_SKIN_URL="https://raw.githubusercontent.com/derailed/k9s/refs/heads/master/skins/transparent.yaml"

mkdir -p "${K9S_CONFIG_DIR}"

cat > "${K9S_CONFIG_FILE}" <<'EOF'
k9s:
  ui:
    skin: transparent
EOF

if command -v curl >/dev/null 2>&1; then
  curl -fsSL "${K9S_SKIN_URL}" -o "${K9S_SKIN_FILE}"
elif command -v wget >/dev/null 2>&1; then
  wget -qO "${K9S_SKIN_FILE}" "${K9S_SKIN_URL}"
else
  echo "Neither curl nor wget is installed; cannot download k9s transparent skin." >&2
  exit 1
fi
