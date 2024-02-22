# Path
export PATH="$HOME/.local/bin:$PATH"

# Default editor managed by update-alternatives
export EDITOR="editor"

# XDG Directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

# Cleanup Home
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export HISTFILE="$XDG_CACHE_HOME/history"
export GIT_CONFIG_GLOBAL="$XDG_CONFIG_HOME/git/.gitconfig"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export LESSHISTFILE="$XDG_CACHE_HOME/less/history"
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc"

# nvm
export NVM_DIR="$XDG_CONFIG_HOME/nvm"
# nvm end

# pnpm
export PNPM_HOME="$XDG_DATA_HOME/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# bun
export BUN_INSTALL="$XDG_DATA_HOME/bun"
export PATH="$BUN_INSTALL/bin:$PATH"
# bun end

# go
export GOPATH="$XDG_DATA_HOME/go"
export GOMODCACHE="$XDG_CACHE_HOME/go/mod"
export PATH="$GOPATH/bin:$PATH"
# go end

