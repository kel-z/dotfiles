# dotfiles

kel-z dotfiles

## dependencies

install with homebrew:

```bash
# if not installed already
brew install stow neovim tmux yazi git zsh

# nvim plugin dependencies
brew install jq ripgrep fd fzf make markdownlint-cli2
brew install --cask font-hack-nerd-font

# omz plugins
brew install zsh-autocomplete zsh-autosuggestions zsh-syntax-highlighting zsh-vi-mode

# p10k
brew install powerlevel10k
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
stow git # optional
```
