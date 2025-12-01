# p10k instant prompt init
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${USER}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${USER}.zsh"
fi
# zsh
export ZSH="$HOME/.oh-my-zsh"
export NVM_LAZY_LOAD=true
zstyle ':omz:update' mode auto
DISABLE_UNTRACKED_FILES_DIRTY="true"
plugins=(
  git
  zsh-autosuggestions
  zsh-vi-mode
  zsh-nvm
  zsh-syntax-highlighting
)
export DEFAULT_USER="$(whoami)"
source $ZSH/oh-my-zsh.sh
export EDITOR='nvim'
# yazi
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}

# config aliases
alias zshc="nvim ~/.zshrc"
alias szsh="source ~/.zshrc"
alias sshc="nvim ~/.ssh/config"

alias nvimi="nvim ~/.config/nvim/init.lua"
alias nvimp="cd ~/.config/nvim/lua/plugins/"

alias tmuxc="nvim ~/.tmux.conf"
alias stmux="tmux source-file ~/.tmux.conf"

alias alac="nvim ~/.config/alacritty/alacritty.toml"

# misc aliases
alias nv="nvim"
alias o="nvim ."

# zsh local
alias zshcl="nvim ~/.zshrc.local"
if [[ -f ~/.zshrc.local ]]; then
  source ~/.zshrc.local
fi
# p10k config
if [[ -d ~/powerlevel10k ]]; then
  source ~/powerlevel10k/powerlevel10k.zsh-theme
elif command -v brew >/dev/null 2>&1; then
  source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme
fi
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

