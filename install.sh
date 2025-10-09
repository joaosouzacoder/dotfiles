#!/bin/bash

# ===============================================
# Cross-platform Development Environment Setup
# Supports: macOS + Linux (Debian/Ubuntu)
# ===============================================

set -euo pipefail

echo "🚀 Configurando ambiente de desenvolvimento..."
echo ""

# ===============================================
# Helper Functions
# ===============================================

print_section() {
    echo ""
    echo "📦 $1"
    echo "=================================="
}

check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        echo "✅ $1 já está instalado"
        return 0
    else
        echo "❌ $1 não encontrado, instalando..."
        return 1
    fi
}

# ===============================================
# Detect OS
# ===============================================

OS="$(uname -s | tr '[:upper:]' '[:lower:]')"

if [[ "$OS" == "darwin" ]]; then
    PLATFORM="macOS"
    HOMEBREW_PREFIX="/opt/homebrew"
elif [[ "$OS" == "linux" ]]; then
    PLATFORM="Linux"
    HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
else
    echo "❌ Sistema não suportado: $OS"
    exit 1
fi

echo "🔍 Sistema detectado: $PLATFORM"
export PATH="$HOMEBREW_PREFIX/bin:$PATH"

# ===============================================
# 0. Linux prerequisites
# ===============================================

if [[ "$PLATFORM" == "Linux" ]]; then
    print_section "Instalando dependências básicas no Linux"
    apt-get update -y
    apt-get install -y curl git sudo build-essential unzip xz-utils
fi

# ===============================================
# 1. Install Homebrew
# ===============================================

print_section "Instalando Homebrew"

if ! check_command "brew"; then
    echo "📥 Instalando Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "🔄 Atualizando Homebrew..."
    brew update
fi

# ===============================================
# 2. Install Core Development Tools
# ===============================================

print_section "Instalando ferramentas essenciais via Homebrew"

BREW_PACKAGES=(
    git
    curl
    stow
    wget
    tree
    jq
    yq
    zsh
    eza
    bat
    fzf
    ripgrep
    fd
    neovim
    tmux
    direnv
    reattach-to-user-namespace
    kubectl
    helm
    docker
    docker-compose
    htop
    gh
    pnpm
)

for package in "${BREW_PACKAGES[@]}"; do
    if brew list "$package" >/dev/null 2>&1; then
        echo "✅ $package já está instalado"
    else
        echo "📥 Instalando $package..."
        brew install "$package"
    fi
done

# ===============================================
# 3. Install GUI Applications (only macOS)
# ===============================================

if [[ "$PLATFORM" == "macOS" ]]; then
    print_section "Instalando aplicações GUI via Homebrew Cask"

    CASK_PACKAGES=(
        visual-studio-code
        postman
        spotify
    )

    for cask in "${CASK_PACKAGES[@]}"; do
        if brew list --cask "$cask" >/dev/null 2>&1; then
            echo "✅ $cask já está instalado"
        else
            echo "📥 Instalando $cask..."
            brew install --cask "$cask"
        fi
    done
else
    echo "⚠️ Pacotes GUI não disponíveis no Linux via cask"
fi

if [[ "$PLATFORM" == "macOS" ]]; then
    print_section "Instalando aerospace"

    if ! check_command "aerospace"; then

        print_section "Instalando"
        brew tap nikitabobko/tap
        brew install --cask aerospace
    fi
fi

# ===============================================
# 4. Setup Oh My Zsh
# ===============================================

print_section "Configurando Oh My Zsh"

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "📥 Instalando Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "✅ Oh My Zsh já está instalado"
fi

# Plugins
print_section "Instalando plugins ZSH"

if [ ! -d "$HOME/.zsh/zsh-autosuggestions" ]; then
    mkdir -p ~/.zsh
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
    echo "✅ zsh-autosuggestions instalado"
else
    echo "✅ zsh-autosuggestions já está instalado"
fi

# ===============================================
# 5. Setup ASDF and Language Runtimes
# ===============================================

echo "INSTALANDO ASDF"

if [ ! -d "$HOME/.asdf" ]; then
    git clone https://github.com/asdf-vm/asdf.git "$HOME/.asdf" --branch v0.14.1
else
    echo "✅ ASDF já está clonado em $HOME/.asdf"
fi
print_section "Configurando ASDF e linguagens"

if [ -f "$HOME/.asdf/asdf.sh" ]; then
    source "$HOME/.asdf/asdf.sh"
fi

ASDF_PLUGINS=(java nodejs dotnet-core)

for plugin in "${ASDF_PLUGINS[@]}"; do
    if asdf plugin list | grep -q "$plugin"; then
        echo "✅ ASDF plugin $plugin já está instalado"
    else
        asdf plugin add "$plugin"
    fi
done

# ===============================================
# 10. Dotfiles
# ===============================================

print_section "Aplicando dotfiles com stow"

if [ -d "$HOME/dotfiles" ]; then
    mkdir -p "$HOME/.config"
    cd ~/dotfiles
    stow .
else
    echo "⚠️ Nenhum diretório ~/dotfiles encontrado, pulei esta etapa"
fi

# Java 21
if ! asdf list java | grep -q "zulu-21"; then
    asdf install java zulu-21.40.17
    asdf global java zulu-21.40.17
fi

# Node.js LTS
if ! asdf list nodejs | grep -q "20"; then
    asdf install nodejs 22.14.0
    asdf global nodejs 22.14.0
fi

# .NET 8
if ! asdf list dotnet-core | grep -q "8."; then
    asdf install dotnet-core 8.0.403
    asdf global dotnet-core 8.0.403
fi

echo "export ZDOTDIR=$HOME/.config/zshrc" >~/.zshenv
echo ". $HOME/.cargo/env" >>~/.zshenv
#source ~/.config/zshrc/.zshrc

# ===============================================
# 6. Additional Tools
# ===============================================

print_section "Instalando gerenciadores de pacotes adicionais"

check_command bun || curl -fsSL https://bun.sh/install | bash
check_command deno || curl -fsSL https://deno.land/install.sh | sh

check_command rustup || curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | RUSTUP_INIT_SKIP_PATH_CHECK=yes sh -s -- -y
# ===============================================
# 7. Kubernetes Tools
# ===============================================

print_section "Configurando ferramentas Kubernetes"

if ! kubectl krew version >/dev/null 2>&1; then
    echo "📥 Instalando Krew..."
    (
        set -x
        cd "$(mktemp -d)"
        OS_LOWER="$(uname | tr '[:upper:]' '[:lower:]')"
        ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')"
        KREW="krew-${OS_LOWER}_${ARCH}"
        curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz"
        tar zxvf "${KREW}.tar.gz"
        ./"${KREW}" install krew
    )
fi

# ===============================================
# 8. Android SDK
# ===============================================

print_section "Configurando Android SDK (opcional)"

if [[ "$PLATFORM" == "macOS" ]]; then
    ANDROID_SDK="$HOME/Library/Android/sdk"
else
    ANDROID_SDK="$HOME/Android/Sdk"
fi

if [ ! -d "$ANDROID_SDK" ]; then
    mkdir -p "$ANDROID_SDK"
    cd "$ANDROID_SDK"
    curl -o commandlinetools.zip https://dl.google.com/android/repository/commandlinetools-mac-11076708_latest.zip
    unzip -o commandlinetools.zip
    mkdir -p cmdline-tools/latest
    mv cmdline-tools/* cmdline-tools/latest/ 2>/dev/null || true
    rm commandlinetools.zip
else
    echo "✅ Android SDK já está configurado"
fi

# ===============================================
# 9. Directories & Lombok
# ===============================================

print_section "Criando diretórios e configurando Lombok"

mkdir -p "$HOME/.local/bin" "$HOME/.config" "$HOME/.local/share/java"

LOMBOK_PATH="$HOME/.local/share/java/lombok.jar"
if [ ! -f "$LOMBOK_PATH" ]; then
    curl -L -o "$LOMBOK_PATH" https://projectlombok.org/downloads/lombok.jar
    echo "✅ Lombok instalado"
fi

# ===============================================
# 11. Final
# ===============================================

print_section "Finalizando configuração"

echo "🔄 Recarregando shell..."
source "$HOME/.zshrc" 2>/dev/null || true

echo ""
echo "🎉 Configuração concluída no $PLATFORM!"

exec zsh -l
