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
  ttf-hack-nerd ttf-dejavu rust \
  swaybg alacritty python3 nodejs npm unzip wget \
  xdg-desktop-portal-wlr polkit-gnome bluez bluez-utils

yay -S wvkbd-deskintl kanata
```

oh-my-zsh:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

# oh-my-zsh writes its own ~/.zshrc — remove it before stowing zsh, or it
# moves the stowed symlink aside and replaces your config with the template
rm -f ~/.zshrc
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
stow sway waybar wlsunset wofi gtk flameshot scripts kanata omp

# powerlevel10k — not on the AUR under this name; the zshrc expects the clone
# at ~/powerlevel10k (macOS: brew install powerlevel10k works via the zshrc's
# brew-prefix fallback)
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k

# kanata
sudo groupadd uinput
sudo usermod -aG input,uinput $USER
sudo tee /etc/udev/rules.d/99-uinput.rules <<< 'KERNEL=="uinput", GROUP="uinput", MODE="0660", OPTIONS+="static_node=uinput"'
sudo udevadm control --reload-rules && sudo udevadm trigger
# log out and back in for group membership
```

## screen rotation

`scripts/.local/bin/sway-rotate-screen.sh` needs `iio-sensor-proxy`, `python3`,
and a running sway session. The touchscreen/stylus identifiers at the top of
the script are **machine-specific** — set them from `swaymsg -t get_inputs`
(Wacom device names differ per model; the defaults in this repo are from one
machine and will likely differ from yours). Rotation lock flag: `~/.rotation_lock`.

## agents (opencode · oh-my-pi · claude code)

```bash
sudo pacman -S --needed opencode bun-bin
sudo npm install -g @oh-my-pi/pi-coding-agent
curl -fsSL https://claude.ai/install.sh | bash
```

- `~/.omp/agent/models.yml` is machine-local (tailnet URLs, provider config) — never commit it.
- `~/.local/bin/cc-oauth-wrapper.sh` (claude oauth) is machine-local too — not stowed.

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
dies.

this has to be **polled**, not event-driven. the EC query handler for AC
plug/unplug on this machine (`_Q27`) aborts on an AML firmware bug
(`AE_AML_PACKAGE_LIMIT` in `BRNS`), so no power_supply uevent is ever emitted --
upower's own cached state goes stale too. sysfs still reads correctly on demand:

```bash
sudo tee /usr/local/bin/lid-ac-unplug <<'EOF'
#!/bin/bash
# Suspend if the charger is gone while the lid is shut.
#
# Polled, not event-driven: this laptop's EC query handler for AC plug/unplug
# (_Q27) aborts on an AML firmware bug (AE_AML_PACKAGE_LIMIT in BRNS), so no
# power_supply uevent is ever emitted -- even upower's cached state goes stale.
# sysfs still reads correctly on demand, so poll it.
#
# Needed because logind picks the lid action once, at lid-close, and with
# HandleLidSwitchExternalPower=ignore an unplug afterwards goes unnoticed until
# upowerd suspends at PercentageAction=2%.

# Anything still feeding us? Not an unplug.
for online in /sys/class/power_supply/*/online; do
    [ -r "$online" ] && [ "$(cat "$online")" = "1" ] && exit 0
done

# Clamshell: logind ignores the lid when >1 display is connected. Match it, or
# we would suspend a docked session the moment it ran on battery.
connected=$(grep -lx connected /sys/class/drm/card*-*/status 2>/dev/null | wc -l)
[ "$connected" -gt 1 ] && exit 0

# Ask logind, which owns the lid and tracks the switch device directly.
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
# Polled every 30s; without this the start/stop pair buries the journal in
# ~8k lines a day, which is where lid bugs actually get diagnosed.
LogLevelMax=warning
EOF

sudo tee /etc/systemd/system/lid-ac-unplug.timer <<'EOF'
[Unit]
Description=Poll for charger unplugged while the lid is shut

[Timer]
OnBootSec=2min
OnUnitActiveSec=30s
AccuracySec=5s

[Install]
WantedBy=timers.target
EOF

sudo systemctl daemon-reload
sudo systemctl reload systemd-logind
sudo systemctl enable --now lid-ac-unplug.timer
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
