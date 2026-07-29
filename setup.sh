#!/usr/bin/env bash
set -euo pipefail

BREW="${BREW:-/home/linuxbrew/.linuxbrew/bin/brew}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

append_line_if_missing() {
  local line="$1"
  local file="$2"

  touch "$file"
  if ! grep -Fqx "$line" "$file"; then
    echo "$line" >> "$file"
  fi
}

append_block_if_missing() {
  local marker="$1"
  local block="$2"
  local file="$3"

  touch "$file"
  if ! grep -Fq "$marker" "$file"; then
    printf '\n%s\n' "$block" >> "$file"
  fi
}

clone_zsh_plugin_if_missing() {
  local name="$1"
  local repo="$2"
  local target="$3"
  shift 3

  if [[ -d "$target" ]]; then
    echo "==> ${name} already installed, skipping."
    return
  fi

  echo "==> Installing ${name}..."
  git clone "$@" "$repo" "$target"
}

# ── 1. Zsh & Oh My Zsh ────────────────────────────────────────────────────────
ZSH_APT_PACKAGES=()
if ! command -v zsh &>/dev/null; then
  ZSH_APT_PACKAGES+=(zsh)
fi
if ! command -v git &>/dev/null; then
  ZSH_APT_PACKAGES+=(git)
fi

if (( ${#ZSH_APT_PACKAGES[@]} > 0 )); then
  echo "==> Installing ${ZSH_APT_PACKAGES[*]}..."
  sudo NEEDRESTART_MODE=a apt-get update -y
  sudo NEEDRESTART_MODE=a apt-get install -y "${ZSH_APT_PACKAGES[@]}"
else
  echo "==> zsh and git already installed, skipping."
fi

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "==> Installing Oh My Zsh..."
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "==> Oh My Zsh already installed, skipping."
fi

if [[ ! -f "$SCRIPT_DIR/.zshrc" ]]; then
  echo "ERROR: $SCRIPT_DIR/.zshrc not found." >&2
  exit 1
fi

echo "==> Copying .zshrc to $HOME/.zshrc..."
install -m 0644 "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"

ZSH_DIR="$HOME/.oh-my-zsh"
ZSH_CUSTOM_DIR="$ZSH_DIR/custom"
ZSH_PLUGIN_DIR="$ZSH_CUSTOM_DIR/plugins"
mkdir -p "$ZSH_PLUGIN_DIR"

clone_zsh_plugin_if_missing "zsh-autosuggestions" \
  "https://github.com/zsh-users/zsh-autosuggestions.git" \
  "$ZSH_PLUGIN_DIR/zsh-autosuggestions"
clone_zsh_plugin_if_missing "zsh-syntax-highlighting" \
  "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
  "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting"
clone_zsh_plugin_if_missing "fast-syntax-highlighting" \
  "https://github.com/zdharma-continuum/fast-syntax-highlighting.git" \
  "$ZSH_PLUGIN_DIR/fast-syntax-highlighting"

# ── 2. Homebrew ───────────────────────────────────────────────────────────────
if ! command -v brew &>/dev/null && [[ ! -x "$BREW" ]]; then
  echo "==> Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  sudo NEEDRESTART_MODE=a apt-get update -y
  sudo NEEDRESTART_MODE=a apt-get install -y build-essential
else
  echo "==> Homebrew already installed, skipping."
fi

if command -v brew &>/dev/null; then
  BREW="$(command -v brew)"
fi

eval "$("$BREW" shellenv)"

# Persist brew env to shell configs
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
  append_line_if_missing 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' "$rc"
done

# ── 3. Docker ─────────────────────────────────────────────────────────────────
if ! command -v docker &>/dev/null; then
  echo "==> Installing Docker..."
  sudo NEEDRESTART_MODE=a apt-get update -y
  sudo NEEDRESTART_MODE=a apt-get install -y ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo NEEDRESTART_MODE=a apt-get update -y
  sudo NEEDRESTART_MODE=a apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo groupadd docker 2>/dev/null || true
  sudo usermod -aG docker "$USER"
  echo "==> Docker installed. Re-login (or run 'newgrp docker') for group membership to take effect."
else
  echo "==> Docker already installed, skipping."
fi

# ── 4. Go ─────────────────────────────────────────────────────────────────────
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

# ── 5. Brew packages ──────────────────────────────────────────────────────────
echo "==> Installing brew packages..."
CI=1 HOMEBREW_NO_ENV_HINTS=1 "$BREW" install kubectl helm kind k9s uv pre-commit lazygit python@3.12 node fzf fd neovim ripgrep copilot-cli </dev/null

append_line_if_missing 'eval "$(fzf --bash)"' "$HOME/.bashrc"
append_line_if_missing 'eval "$(fzf --zsh)"' "$HOME/.zshrc"

append_line_if_missing 'alias lg="lazygit"' "$HOME/.bashrc"
append_line_if_missing 'alias lg="lazygit"' "$HOME/.zshrc"

# ── 6. Midnight Commander ─────────────────────────────────────────────────────
if ! command -v mc &>/dev/null; then
  echo "==> Installing Midnight Commander..."
  sudo NEEDRESTART_MODE=a apt-get update -y
  sudo NEEDRESTART_MODE=a apt-get install -y mc
else
  echo "==> Midnight Commander already installed, skipping."
fi


echo "==> Writing ~/.tmux/shell_env_sync.sh..."
mkdir -p "$HOME/.tmux"
cat > "$HOME/.tmux/shell_env_sync.sh" <<'EOF'
#!/usr/bin/env bash

if [[ -n "${TMUX:-}" ]] && command -v tmux >/dev/null 2>&1; then
  __tmux_sync_env() {
    local now
    now="$(date +%s)"

    if [[ -z "${__TMUX_LAST_ENV_SYNC:-}" ]] || (( now - __TMUX_LAST_ENV_SYNC >= 5 )); then
      eval "$(tmux show-env -s)"
      __TMUX_LAST_ENV_SYNC="$now"
    fi
  }

  if [[ -n "${BASH_VERSION:-}" ]]; then
    case ";${PROMPT_COMMAND:-};" in
      *";__tmux_sync_env;"*) ;;
      *)
        if [[ -n "${PROMPT_COMMAND:-}" ]]; then
          PROMPT_COMMAND="__tmux_sync_env; ${PROMPT_COMMAND}"
        else
          PROMPT_COMMAND="__tmux_sync_env"
        fi
        ;;
    esac
  fi

  if [[ -n "${ZSH_VERSION:-}" ]]; then
    autoload -Uz add-zsh-hook
    add-zsh-hook precmd __tmux_sync_env
  fi

  __tmux_sync_env
fi
EOF
chmod +x "$HOME/.tmux/shell_env_sync.sh"

append_block_if_missing '# tmux shell env sync' '# tmux shell env sync
[[ -f "$HOME/.tmux/shell_env_sync.sh" ]] && source "$HOME/.tmux/shell_env_sync.sh"' "$HOME/.bashrc"
append_block_if_missing '# tmux shell env sync' '# tmux shell env sync
[[ -f "$HOME/.tmux/shell_env_sync.sh" ]] && source "$HOME/.tmux/shell_env_sync.sh"' "$HOME/.zshrc"

# ── 7. Claude Code & Codex (native installers) ────────────────────────────────
# Both native installers place their binary in ~/.local/bin.
export PATH="$HOME/.local/bin:$PATH"
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
  append_line_if_missing 'export PATH="$HOME/.local/bin:$PATH"' "$rc"
done

if ! command -v claude &>/dev/null; then
  echo "==> Installing Claude Code (native installer)..."
  curl -fsSL https://claude.ai/install.sh | bash
else
  echo "==> Claude Code already installed, skipping."
fi

if ! command -v codex &>/dev/null; then
  echo "==> Installing Codex (native installer)..."
  curl -fsSL https://chatgpt.com/codex/install.sh | CODEX_NON_INTERACTIVE=1 sh
else
  echo "==> Codex already installed, skipping."
fi

# ── 7. .tmux.conf ─────────────────────────────────────────────────────────────
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

set -g status-right "#(~/.tmux/git_status.sh #{pane_current_path})"
set -g status-interval 5
EOF

echo "==> Writing ~/.tmux/git_status.sh..."
mkdir -p "$HOME/.tmux"
cat > "$HOME/.tmux/git_status.sh" <<'EOF'
#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 1 ]]; then
  exit 0
fi

cd "$1" || exit 0

branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
if [[ -n "$branch" && "$branch" != "HEAD" ]]; then
  echo "#[fg=colour10] $branch"
fi
EOF
chmod +x "$HOME/.tmux/git_status.sh"
cp -r nvim $HOME/.config/ 
cp fgcolor.zsh-theme $HOME/.oh-my-zsh/custom/themes
cp .tmux.conf $HOME/ 
cp .zshrc $HOME/

echo ""
echo "==> Setup complete."
echo "    Run 'source ~/.bashrc' or 'source ~/.zshrc' (or open a new shell) to reload PATH."
echo "    If Docker group was just added, run 'newgrp docker' or re-login."
echo "    Installed zsh: $(zsh --version)"
echo "    Installed Node: $(node --version)"
echo "    Installed npm: $(npm --version)"
echo "    Installed Claude Code: $(claude --version)"
echo "    Installed Codex: $(codex --version)"
