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

## lid close (suspend + hibernate)

these are system files, so they are **not** stowed and there is no install
script -- paste the blocks below. stow is the wrong tool here: `/home` is a
separate filesystem, so a symlink into `~/dotfiles` is dangling when udev reads
its rules in early boot, and a root-executed script must not sit on a
user-writable path.

power policy lives in logind, not sway. `bindswitch` silently dropped a lid
event once and the laptop ran shut in a bag until upowerd suspended it at 2%
battery. logind reads the switch device directly, does clamshell natively, and
debounces lid events for 30s after resume (`HoldoffTimeoutSec`). the stowed
`on-lid-close.sh` is display-only and nothing power-related may depend on it.

```bash
# logind owns the lid. "docked" means >1 display connected, i.e. clamshell.
sudo mkdir -p /etc/systemd/logind.conf.d
sudo tee /etc/systemd/logind.conf.d/90-lid-clamshell.conf <<'EOF'
[Login]
HandleLidSwitch=suspend-then-hibernate
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
EOF

# with a battery present, systemd escalates suspend -> hibernate ONLY on the
# ACPI _BTP 5% trip unless this is set. the documented 2h default for
# HibernateDelaySec applies only to systems with NO battery.
sudo mkdir -p /etc/systemd/sleep.conf.d
sudo tee /etc/systemd/sleep.conf.d/90-hibernate-delay.conf <<'EOF'
[Sleep]
HibernateDelaySec=30min
EOF
```

`HandleLidSwitchExternalPower=ignore` keeps the laptop awake while charging. but
logind picks the lid action once, at lid-close, and never subscribes to
power_supply udev -- so unplugging afterwards goes unnoticed until the battery
dies. this covers that:

```bash
sudo tee /usr/local/bin/lid-ac-unplug <<'EOF'
#!/bin/bash
# Suspend if the lid is already shut when the charger is pulled.
for online in /sys/class/power_supply/*/online; do
    [ -r "$online" ] && [ "$(cat "$online")" = "1" ] && exit 0
done
[ "$(busctl get-property org.freedesktop.login1 /org/freedesktop/login1 \
     org.freedesktop.login1.Manager LidClosed)" = "b true" ] || exit 0
systemctl suspend-then-hibernate
EOF
sudo chmod 755 /usr/local/bin/lid-ac-unplug

sudo tee /etc/systemd/system/lid-ac-unplug.service <<'EOF'
[Unit]
Description=Suspend if the lid is shut when the charger is unplugged
ConditionPathExists=/sys/class/power_supply/AC

[Service]
Type=oneshot
ExecStart=/usr/local/bin/lid-ac-unplug
EOF

# BAT0 has no "online" attribute, so battery churn does not match this rule.
sudo tee /etc/udev/rules.d/90-lid-ac-unplug.rules <<'EOF'
ACTION=="change", SUBSYSTEM=="power_supply", ATTR{online}=="0", \
  RUN+="/usr/bin/systemctl --no-block start lid-ac-unplug.service"
EOF

sudo systemctl daemon-reload
sudo systemctl reload systemd-logind
sudo udevadm control --reload-rules
```

hibernate additionally needs `resume=` on the kernel command line pointing at the
swap device, and swap large enough to hold the image -- 8G of swap cannot
hibernate a session using 10G of RAM.

verifying, after a lid close:

```bash
# 'suspend' then 'hibernate' ~30min later is the healthy pattern
journalctl -b 0 | grep "Performing sleep operation"

# who asked. 'upowerd' means nothing else caught it and the battery hit 2%
journalctl -b 0 | grep "suspend-then-hibernate requested"

# live logind view
busctl get-property org.freedesktop.login1 /org/freedesktop/login1 \
  org.freedesktop.login1.Manager HandleLidSwitch
```
