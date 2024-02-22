#!/usr/bin/env sh

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

source "$ZDOTDIR/zsh-functions"

# Source files
zsh_add_file "zsh-exports"
zsh_add_file "zsh-aliases"
zsh_add_file "zsh-prompt"
zsh_add_file "zsh-vim"

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)


# Add plugins
plugins=(
    "zsh-users/zsh-autosuggestions"
    "zsh-users/zsh-syntax-highlighting"
    "zsh-users/zsh-completions"
)

for plugin in "${plugins[@]}"; do
    zsh_add_plugin $plugin
done

# pnpm
export PNPM_HOME="/home/r/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# bit
export PATH="$PATH:/home/r/bin"
# bit end

# bun completions
[ -s "/home/r/.bun/_bun" ] && source "/home/r/.bun/_bun"

# rust
. "/home/r/.local/share/cargo/env"
