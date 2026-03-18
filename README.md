# dotfiles

kel-z dotfiles

## dependencies

install with homebrew (macOS):

```bash
# if not installed already
brew install stow neovim tmux yazi git zsh

# nvim plugin dependencies
brew install jq ripgrep fd fzf make markdownlint-cli2
brew install --cask font-hack-nerd-font

# omz plugins
brew install zsh-autosuggestions zsh-syntax-highlighting

# p10k
brew install powerlevel10k
```

install with pacman (Arch Linux):

```bash
sudo pacman -S stow neovim tmux yazi git zsh \
  jq ripgrep fd fzf make \
  sway waybar wofi wlsunset flameshot \
  swaylock swayidle wl-clipboard cliphist grim \
  brightnessctl pipewire pipewire-pulse \
  iio-sensor-proxy \
  zsh-autosuggestions zsh-syntax-highlighting \
  ttf-hack-nerd-fonts ttf-dejavu
```

AUR packages (e.g. with `yay`):

```bash
yay -S wvkbd-deskintl powerlevel10k kanata
```

install oh-my-zsh:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

install submodules:

```bash
git submodule update --init --recursive --remote
```

## setup

clone and stow (assumes no existing config):

```bash
brew install stow

git clone https://github.com/kel-z/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow zsh tmux nvim yazi
stow alacritty # if using alacritty as terminal
stow opencode # if using opencode
stow git # optional

# arch linux
stow kanata
# kanata (one-time system setup)
sudo groupadd uinput
sudo usermod -aG input,uinput $USER
sudo tee /etc/udev/rules.d/99-uinput.rules <<< 'KERNEL=="uinput", GROUP="uinput", MODE="0660", OPTIONS+="static_node=uinput"'
sudo udevadm control --reload-rules && sudo udevadm trigger
# log out and back in for group membership to take effect

stow sway
stow waybar
stow wlsunset
stow wofi
stow gtk
stow flameshot
stow scripts
```
