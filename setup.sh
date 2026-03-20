#!/usr/bin/env bash
set -euo pipefail

BREW="/home/linuxbrew/.linuxbrew/bin/brew"

# ── 1. Homebrew ───────────────────────────────────────────────────────────────
if ! command -v brew &>/dev/null && [[ ! -x "$BREW" ]]; then
  echo "==> Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  sudo apt-get install -y build-essential
else
  echo "==> Homebrew already installed, skipping."
fi

eval "$($BREW shellenv)"

# Persist brew env to shell configs
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
  if ! grep -q "linuxbrew" "$rc" 2>/dev/null; then
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$rc"
  fi
done

# ── 2. Docker ─────────────────────────────────────────────────────────────────
if ! command -v docker &>/dev/null; then
  echo "==> Installing Docker..."
  sudo apt-get update -y
  sudo apt-get install -y ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update -y
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo groupadd docker 2>/dev/null || true
  sudo usermod -aG docker "$USER"
  echo "==> Docker installed. Re-login (or run 'newgrp docker') for group membership to take effect."
else
  echo "==> Docker already installed, skipping."
fi

# ── 3. Go ─────────────────────────────────────────────────────────────────────
GO_VERSION="1.24.1"
if ! command -v go &>/dev/null; then
  echo "==> Installing Go ${GO_VERSION}..."
  ARCHIVE="go${GO_VERSION}.linux-amd64.tar.gz"
  wget -q "https://go.dev/dl/${ARCHIVE}"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "$ARCHIVE"
  rm -f "$ARCHIVE"
  for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if ! grep -q "/usr/local/go/bin" "$rc" 2>/dev/null; then
      echo 'export PATH=$PATH:/usr/local/go/bin' >> "$rc"
      echo 'export PATH=$PATH:$(go env GOPATH)/bin' >> "$rc"
    fi
  done
  export PATH=$PATH:/usr/local/go/bin
else
  echo "==> Go already installed ($(go version)), skipping."
fi

# ── 4. Brew packages ──────────────────────────────────────────────────────────
echo "==> Installing brew packages..."
brew install kubectl helm k9s uv prek lazygit python@3.12

# ── 5. .tmux.conf ─────────────────────────────────────────────────────────────
echo "==> Writing ~/.tmux.conf..."
cat > "$HOME/.tmux.conf" <<'EOF'
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R
set-option -g history-limit 10000
set-option -a terminal-features 'xterm-256color:RGB'
set-option -sg escape-time 10
set-option -g focus-events on

set-window-option -g mode-keys vi
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
EOF

echo ""
echo "==> Setup complete."
echo "    Run 'source ~/.bashrc' (or open a new shell) to reload PATH."
echo "    If Docker group was just added, run 'newgrp docker' or re-login."
