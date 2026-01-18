# p10k instant prompt init
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${USER}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${USER}.zsh"
fi
# zsh
export ZSH="$HOME/.oh-my-zsh"
zstyle ':omz:update' mode auto
DISABLE_UNTRACKED_FILES_DIRTY="true"
if command -v brew >/dev/null 2>&1; then
  source $(brew --prefix)/opt/zsh-autosuggestions/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  source $(brew --prefix)/opt/zsh-syntax-highlighting/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
plugins=(
  git
  vi-mode
)
export DEFAULT_USER="$(whoami)"
VI_MODE_SET_CURSOR=true
KEYTIMEOUT=1
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
alias zshc="nvim ~/dotfiles/zsh/.zshrc"
alias szsh="source ~/.zshrc"
alias sshc="nvim ~/.ssh/config"

alias nvimi="nvim ~/dotfiles/nvim/.config/nvim/init.lua"
alias nvimp="cd ~/.config/nvim/lua/plugins/"
alias nvimt="cd ~/.config/nvim/lua/themes/"

alias tmuxc="nvim ~/dotfiles/tmux/.tmux.conf"
alias tmuxp="cd ~/dotfiles/tmux/.tmux/plugins/"
alias stmux="tmux source-file ~/.tmux.conf"

alias alac="nvim ~/dotfiles/alacritty/.config/alacritty/alacritty.toml"

# misc aliases
alias o="nvim ."

# zsh local
alias zshcl="nvim ~/.zshrc.local"
if [[ -f ~/.zshrc.local ]]; then
  source ~/.zshrc.local
fi

# theme map ([alacritty]: nvim)
declare -A THEME_MAPPINGS=(
  ["kanagawa"]="jetbrains"
  ["solarized"]="solarized"
)

# theme switching impl
ALACRITTY_CONFIG="$HOME/dotfiles/alacritty/.config/alacritty/alacritty.toml"
NVIM_THEMES_DIR="$HOME/dotfiles/nvim/.config/nvim/lua/themes"
_get_current_alacritty_theme() {
  local current_theme
  current_theme=$(grep -o 'themes/themes/[^"]*\.toml' "$ALACRITTY_CONFIG" 2>/dev/null | head -1)
  if [[ -n "$current_theme" ]]; then
    echo "${current_theme##*/}" | sed 's/\.toml$//'
  else
    echo "unknown"
  fi
}
_get_current_neovim_theme() {
  local enabled_theme
  enabled_theme=$(grep -l 'enabled = true' "$NVIM_THEMES_DIR"/*.lua 2>/dev/null | head -1)
  if [[ -n "$enabled_theme" ]]; then
    echo "${enabled_theme##*/}" | sed 's/\.lua$//'
  else
    echo "none"
  fi
}
_validate_theme() {
  local theme_name="$1"
  # check if theme exists
  if [[ -z "${THEME_MAPPINGS[$theme_name]}" ]]; then
    echo "Error: Theme '$theme_name' not found in theme mappings."
    echo "Available themes: ${(k)THEME_MAPPINGS}"
    return 1
  fi
  # check for alacritty setup
  local alacritty_theme_file="$ALACRITTY_CONFIG/themes/themes/${theme_name}_dragon.toml"
  if [[ "$theme_name" == "kanagawa" ]]; then
    alacritty_theme_file="${ALACRITTY_CONFIG%/*}/themes/themes/kanagawa_dragon.toml"
  elif [[ "$theme_name" == "solarized" ]]; then
    alacritty_theme_file="${ALACRITTY_CONFIG%/*}/themes/themes/solarized_dark.toml"
  fi
  if [[ ! -f "$alacritty_theme_file" ]]; then
    echo "Error: Alacritty theme file not found: $alacritty_theme_file"
    return 1
  fi
  # check for nvim setup
  local nvim_theme_name="${THEME_MAPPINGS[$theme_name]}"
  local nvim_theme_file="$NVIM_THEMES_DIR/${nvim_theme_name}.lua"
  if [[ ! -f "$nvim_theme_file" ]]; then
    echo "Error: Neovim theme file not found: $nvim_theme_file"
    return 1
  fi
  return 0
}
_set_alacritty_theme() {
  local theme_name="$1"
  local alacritty_theme_file
  if [[ "$theme_name" == "kanagawa" ]]; then
    alacritty_theme_file="themes/themes/kanagawa_dragon.toml"
  elif [[ "$theme_name" == "solarized" ]]; then
    alacritty_theme_file="themes/themes/solarized_dark.toml"
  fi
  # update the theme
  sed -i '' "s|    \"themes/themes/.*\.toml\"|    \"$alacritty_theme_file\"|" "$ALACRITTY_CONFIG"
  echo "Updated Alacritty theme to: $alacritty_theme_file"
}
_validate_enabled_line() {
  local theme_file="$1"
  local line_3_content
  line_3_content=$(sed -n '3p' "$theme_file" 2>/dev/null)
  if [[ ! "$line_3_content" =~ ^[[:space:]]*enabled[[:space:]]*=[[:space:]]*(true|false)[[:space:]]*,?[[:space:]]*$ ]]; then
    echo "Error: Line 3 of $theme_file does not contain expected 'enabled = true/false' format."
    echo "Found: '$line_3_content'"
    return 1
  fi
  return 0
}
_set_neovim_theme() {
  local theme_name="$1"
  local nvim_theme_name="${THEME_MAPPINGS[$theme_name]}"
  local current_nvim_theme
  current_nvim_theme=$(_get_current_neovim_theme)
  # disable currently enabled theme (assumed line 3)
  if [[ "$current_nvim_theme" != "none" ]]; then
    local current_theme_file="$NVIM_THEMES_DIR/${current_nvim_theme}.lua"
    if ! _validate_enabled_line "$current_theme_file"; then
      return 1
    fi
    sed -i '' '3s/enabled = true/enabled = false/' "$current_theme_file"
    echo "Disabled Neovim theme: $current_nvim_theme"
  fi
  # enable new theme
  local new_theme_file="$NVIM_THEMES_DIR/${nvim_theme_name}.lua"
  if ! _validate_enabled_line "$new_theme_file"; then
    return 1
  fi
  sed -i '' '3s/enabled = false/enabled = true/' "$new_theme_file"
  echo "Enabled Neovim theme: $nvim_theme_name"
}
# main theme function
theme() {
  local theme_name="$1"
  # windows does not support relative path: https://github.com/alacritty/alacritty-theme/issues/25
  if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]] || [[ "$OSTYPE" == "linux-gnu"* && "$(uname -r)" == *"microsoft"* ]]; then
    echo "Error: Theme switching is not supported on Windows/WSL."
    echo "This function is designed for macOS and native Linux environments only."
    return 1
  fi
  # help
  if [[ "$theme_name" == "--help" ]] || [[ "$theme_name" == "-h" ]]; then
    echo "Theme Management Function"
    echo ""
    echo "Usage:"
    echo "  theme <name>     Switch to specified theme"
    echo "  theme            Show current theme status"
    echo "  theme --list     List available theme mappings"
    echo "  theme --help     Show this help message"
    echo ""
    echo "Available themes: ${(k)THEME_MAPPINGS}"
    return 0
  fi
  # list
  if [[ "$theme_name" == "--list" ]]; then
    echo "Available theme mappings:"
    for theme in ${(k)THEME_MAPPINGS}; do
      echo "  $theme -> ${THEME_MAPPINGS[$theme]}"
    done
    return 0
  fi
  # status
  if [[ -z "$theme_name" ]]; then
    local current_alacritty current_neovim
    current_alacritty=$(_get_current_alacritty_theme)
    current_neovim=$(_get_current_neovim_theme)
    echo "Current Theme Status:"
    echo "  Alacritty: $current_alacritty"
    echo "  Neovim:    $current_neovim"
    echo ""
    echo "Available themes: ${(k)THEME_MAPPINGS}"
    return 0
  fi
  # validate
  if ! _validate_theme "$theme_name"; then
    return 1
  fi
  echo "Current Theme Status:"
  echo "  Alacritty: $(_get_current_alacritty_theme)"
  echo "  Neovim:    $(_get_current_neovim_theme)"
  echo ""
  echo "Switching to theme: $theme_name"
  echo ""
  _set_alacritty_theme "$theme_name"
  _set_neovim_theme "$theme_name"
  echo ""
  echo "Theme switch completed!"
  echo ""
  echo "New Theme Status:"
  echo "  Alacritty: $(_get_current_alacritty_theme)"
  echo "  Neovim:    $(_get_current_neovim_theme)"
}

# p10k config
if [[ -d ~/powerlevel10k ]]; then
  source ~/powerlevel10k/powerlevel10k.zsh-theme
elif command -v brew >/dev/null 2>&1; then
  source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme
fi
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

