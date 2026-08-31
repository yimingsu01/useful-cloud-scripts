# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "The time is ${YELLOW}$(date)${NC} and you are on ${BLUE}$(hostname)${NC}"
echo "Welcome back, champion."

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# plugins=(git zsh-autocomplete)
plugins=(git zsh-autosuggestions zsh-syntax-highlighting fast-syntax-highlighting)

# Let Oh My Zsh initialize Docker completions with its normal compinit pass.
fpath=("$HOME/.docker/completions" $fpath)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias lg="lazygit"
alias datefm="date +\"%m_%d_%H_%M_%S\""
alias ll="ls -al"
alias noansi="sed -i 's/\x1b\[[0-9;]*[a-zA-Z]//g'"
alias claude="claude --allow-dangerously-skip-permissions"
export HOMEBREW_PREFIX="/opt/homebrew/"
export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
export HOMEBREW_REPOSITORY="/opt/homebrew"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/sbin:$PATH"
export PATH="/usr/local/bin:$PATH"
export PATH="/usr/local/texlive/2025/bin/universal-darwin:$PATH"
export PATH="/opt/codeql:$PATH"
export PATH="/Users/yms/sdk/go1.23.0/bin:$PATH"
export PATH="/Users/yms/go/bin:$PATH"
export PATH="/Users/yms/.local/bin/zellij/:$PATH"

# PROMPT='%{$fg_bold[white]%}%n'
# PROMPT+=' %{$fg[cyan]%}%~%{$reset_color%} '
PROMPT='%n'
PROMPT+=' %~ '

alias adark="ln -fs ~/.config/alacritty/themes/themes/github_dark.toml ~/.config/alacritty/themes/themes/_active.toml"
alias alight="ln -fs ~/.config/alacritty/themes/themes/github_light.toml ~/.config/alacritty/themes/themes/_active.toml"
func alatheme() {
  ln -fs ~/.config/alacritty/themes/themes/$1.toml ~/.config/alacritty/themes/themes/_active.toml
}


croppdf() {
    # Check if a file path was provided
    if [ -z "$1" ]; then
        echo "Usage: pdf-crop-replace filename.pdf"
        return 1
    fi

    local input_file="$1"
    local base_name="${input_file%.*}"
    local cropped_file="${base_name}-crop.pdf"

    # Run pdfcrop
    if pdfcrop "$input_file"; then
        # If successful, move the cropped file back to the original name
        mv "$cropped_file" "$input_file"
        echo "Successfully cropped and replaced: $input_file"
    else
        echo "Error: pdfcrop failed. Original file preserved."
        return 1
    fi
}

source <(fzf --zsh)

# Ensure SSH/tmux sessions use Unicode rather than the C locale.
export LANG=en_US.UTF-8

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.verus/verus-arm64-macos:$PATH"

export NVM_DIR="$HOME/.nvm"

# Defer NVM's expensive version activation until a Node command is first used.
_nvm_lazy_load() {
  unfunction nvm node npm npx corepack 2>/dev/null
  [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
  [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
  unfunction _nvm_lazy_load 2>/dev/null
}

nvm() { _nvm_lazy_load; nvm "$@"; }
node() { _nvm_lazy_load; command node "$@"; }
npm() { _nvm_lazy_load; command npm "$@"; }
npx() { _nvm_lazy_load; command npx "$@"; }
corepack() { _nvm_lazy_load; command corepack "$@"; }
