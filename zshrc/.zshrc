# ===============================================
# ZSH Configuration
# ===============================================

# Oh My Zsh Configuration
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="awesomepanda"
plugins=(git)

# Custom Prompt
PROMPT='$(prompt_java_version) $(prompt_folder) % '

# Load Oh My Zsh
if [ -f "$ZSH/oh-my-zsh.sh" ]; then
  source "$ZSH/oh-my-zsh.sh"
fi

# ===============================================
# Package Managers & Core Tools
# ===============================================

# Homebrew (macOS vs Linux)
if [[ "$OSTYPE" == "darwin"* ]]; then
  export PATH="/opt/homebrew/bin:$PATH"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
fi

# ASDF Version Manager
if [ -f "$HOME/.asdf/asdf.sh" ]; then
  source "$HOME/.asdf/asdf.sh"
  fpath+=("$HOME/.asdf/completions")
  autoload -U compinit && compinit
fi

# ASDF Plugins - Auto set environment variables
[ -f "$HOME/.asdf/plugins/java/set-java-home.zsh" ] && source "$HOME/.asdf/plugins/java/set-java-home.zsh"
[ -f "$HOME/.asdf/plugins/dotnet-core/set-dotnet-home.zsh" ] && source "$HOME/.asdf/plugins/dotnet-core/set-dotnet-home.zsh"

# RVM Ruby
export PATH="$PATH:$HOME/.rvm/bin"

# ===============================================
# Development Languages & Runtimes
# ===============================================

# Rust
export PATH="$HOME/.cargo/bin:$PATH"

# Node.js - PNPM
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Bun JavaScript Runtime
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# .NET Core
export PATH="$HOME/.dotnet/tools:$PATH"

# Deno
[ -f "$HOME/.deno/env" ] && source "$HOME/.deno/env"

# ===============================================
# Mobile Development
# ===============================================

if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS default Android SDK path
  export ANDROID_HOME="$HOME/Library/Android/sdk"
else
  # Linux default Android SDK path
  export ANDROID_HOME="$HOME/Android/Sdk"
fi
export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$PATH"

# ===============================================
# Cloud & DevOps Tools
# ===============================================

# Kubernetes
export PATH="$HOME/.krew/bin:$PATH"
export KUBE_EDITOR="code --wait"

# Docker Desktop (macOS only)
if [[ "$OSTYPE" == "darwin"* ]]; then
  export PATH="$PATH:/Applications/Docker.app/Contents/Resources/bin/"
fi

# Direnv (Environment Management)
eval "$(direnv hook zsh)"

# ===============================================
# Development Tools & IDEs
# ===============================================

# XDG Base Directory
export XDG_CONFIG_HOME="$HOME/.config"

# Java Development (Lombok support for JDTLS)
export JDTLS_JVM_ARGS="-javaagent:$HOME/.local/share/java/lombok.jar"

# OpenCode (se existir)
[ -d "$HOME/.opencode/bin" ] && export PATH="$HOME/.opencode/bin:$PATH"

# ===============================================
# Custom Scripts & Local Binaries
# ===============================================

export PATH="$HOME/.local/bin:$PATH"
[ -d "$HOME/.scripts" ] && export PATH="$HOME/.scripts:$PATH"

# ===============================================
# Shell Enhancements
# ===============================================

# ZSH Autosuggestions
[ -f "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && source "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"

# ===============================================
# Aliases
# ===============================================

# Editor
alias vim="nvim"

# Kubernetes
alias kc="kubectl"

# File Listing (exa/eza com icons)
if command -v eza >/dev/null 2>&1; then
  alias ll="eza --icons -l --group-directories-first --git --header --long --time-style=long-iso"
elif command -v exa >/dev/null 2>&1; then
  alias ll="exa --icons -l --group-directories-first --git --header --long --time-style=long-iso"
fi

# Development
alias rustl="evcxr"
