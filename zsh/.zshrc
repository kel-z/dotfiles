# p10k instant prompt init
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${USER}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${USER}.zsh"
fi
# zsh
export ZSH="$HOME/.oh-my-zsh"
zstyle ':omz:update' mode auto
DISABLE_UNTRACKED_FILES_DIRTY="true"
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

alias occ="nvim ~/dotfiles/opencode/.config/opencode/opencode.json"

# misc aliases
alias o="nvim ."

# zsh local
alias zshcl="nvim ~/.zshrc.local"
if [[ -f ~/.zshrc.local ]]; then
  source ~/.zshrc.local
fi

# theme configuration [alias_app]=filename
declare -A THEME_CONFIG=(
  ["kanagawa_alacritty"]="kanagawa_dragon"
  ["kanagawa_nvim"]="jetbrains"
  ["solarized_alacritty"]="solarized_dark"
  ["solarized_nvim"]="solarized"
  ["carbonfox_alacritty"]="carbonfox"
  ["carbonfox_nvim"]="carbonfox"
)

# theme switching impl
ALACRITTY_CONFIG="$HOME/dotfiles/alacritty/.config/alacritty/alacritty.toml"
NVIM_THEMES_DIR="$HOME/dotfiles/nvim/.config/nvim/lua/themes"
_get_theme_config() {
  local theme_name="$1"
  local app="$2"
  echo "${THEME_CONFIG[${theme_name}_${app}]}"
}
_get_available_themes() {
  local themes=()
  for key in ${(k)THEME_CONFIG}; do
    if [[ "$key" == *_alacritty ]]; then
      themes+=("${key%_alacritty}")
    fi
  done
  echo "${(u)themes[@]}"
}
_get_alacritty_filename() {
  local theme_name="$1"
  local filename
  filename=$(_get_theme_config "$theme_name" "alacritty")
  if [[ -z "$filename" ]]; then
    return 1
  fi
  echo "themes/themes/${filename}.toml"
}
_get_nvim_filename() {
  local theme_name="$1"
  local filename
  filename=$(_get_theme_config "$theme_name" "nvim")
  if [[ -z "$filename" ]]; then
    return 1
  fi
  echo "${filename}.lua"
}
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
  local alacritty_filename nvim_filename alacritty_path nvim_path
  # check if theme exists in config
  if ! _get_alacritty_filename "$theme_name" >/dev/null 2>&1; then
    echo "Error: Theme '$theme_name' not found in theme configuration."
    echo "Available themes: $(_get_available_themes)"
    return 1
  fi
  # check alacritty theme file exists
  alacritty_filename=$(_get_alacritty_filename "$theme_name")
  alacritty_path="${ALACRITTY_CONFIG%/*}/$alacritty_filename"
  if [[ ! -f "$alacritty_path" ]]; then
    echo "Error: Alacritty theme file not found: $alacritty_path"
    return 1
  fi
  # check nvim theme file exists
  nvim_filename=$(_get_nvim_filename "$theme_name")
  nvim_path="$NVIM_THEMES_DIR/$nvim_filename"
  if [[ ! -f "$nvim_path" ]]; then
    echo "Error: Neovim theme file not found: $nvim_path"
    return 1
  fi
  return 0
}
_set_alacritty_theme() {
  local theme_name="$1"
  local alacritty_theme_file
  alacritty_theme_file=$(_get_alacritty_filename "$theme_name")
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
  local nvim_filename current_nvim_theme
  nvim_filename=$(_get_nvim_filename "$theme_name")
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
  local new_theme_file="$NVIM_THEMES_DIR/$nvim_filename"
  if ! _validate_enabled_line "$new_theme_file"; then
    return 1
  fi
  sed -i '' '3s/enabled = false/enabled = true/' "$new_theme_file"
  echo "Enabled Neovim theme: ${nvim_filename%.lua}"
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
    echo "Available themes: $(_get_available_themes)"
    return 0
  fi
  # list
  if [[ "$theme_name" == "--list" ]]; then
    echo "Available theme mappings:"
    for theme in $(_get_available_themes); do
      alacritty_file=$(_get_alacritty_filename "$theme")
      nvim_file=$(_get_nvim_filename "$theme")
      echo "  $theme -> alacritty: ${alacritty_file#themes/themes/}, nvim: ${nvim_file%.lua}"
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
    echo "Available themes: $(_get_available_themes)"
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
# zsh plugins
if command -v brew >/dev/null 2>&1; then
  source $(brew --prefix)/opt/zsh-autosuggestions/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  source $(brew --prefix)/opt/zsh-syntax-highlighting/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

