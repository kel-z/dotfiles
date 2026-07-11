# dotfiles

kel-z dotfiles

## dependencies

homebrew (macOS):

```bash
brew install stow neovim tmux yazi git zsh
brew install jq ripgrep fd fzf make markdownlint-cli2 tree-sitter-cli
brew install --cask font-hack-nerd-font
brew install powerlevel10k
```

pacman (Arch Linux):

```bash
sudo pacman -S stow neovim tmux yazi git zsh \
  jq ripgrep fd fzf make tree-sitter-cli \
  sway waybar wofi wlsunset flameshot \
  swaylock swayidle wl-clipboard cliphist grim \
  brightnessctl pipewire pipewire-pulse \
  iio-sensor-proxy \
  ttf-hack-nerd ttf-dejavu rustup

yay -S wvkbd-deskintl powerlevel10k kanata
```

oh-my-zsh:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
```

submodules:

```bash
git submodule update --init --recursive
```

## setup

clone and stow (assumes no existing config):

```bash
git clone https://github.com/kel-z/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow zsh tmux nvim yazi
stow alacritty   # if using alacritty
stow opencode    # if using opencode
stow claude      # if using claude code
stow git         # optional
```

arch linux:

```bash
stow sway waybar wlsunset wofi gtk flameshot scripts kanata

# kanata
sudo groupadd uinput
sudo usermod -aG input,uinput $USER
sudo tee /etc/udev/rules.d/99-uinput.rules <<< 'KERNEL=="uinput", GROUP="uinput", MODE="0660", OPTIONS+="static_node=uinput"'
sudo udevadm control --reload-rules && sudo udevadm trigger
# log out and back in for group membership
```
