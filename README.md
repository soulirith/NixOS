NixOS Flake (Niri + Noctalia)

My daily NixOS setup: Wayland compositor (niri), Noctalia theming, NVIDIA Prime offload, zsh + starship.

Prerequisites

NixOS 26.05+
Flakes enabled (experimental-features = [ "nix-command" "flakes" ])
x86_64-linux (aarch64 requires changes to flake.nix + hardware-configuration.nix)

Quick Start

sudo cp -r . /etc/nixos
cd /etc/nixos
sudo doas nixos-rebuild switch --flake .

Adapt for Your Hardware

Edit hardware-configuration.nix (run nixos-generate-config to regenerate):

NVIDIA/AMD GPU: adjust hardware.nvidia.prime PCI IDs in configuration.nix
CPU: kernel params in boot.kernelParams are tuned for Ryzen + NVIDIA

Locale: change time.timeZone and keyboard layout in configuration.nix

Known Gotchas

Home-manager may sometimes create .bak files on conflicts. Clear them:

find ~/.config -name "*.bak" -delete

Noctalia templates: Kitty and Starship are manually edited (not Nix-managed) so Noctalia's live themes can own them. Edit above the # >>> NOCTALIA marker blocks to preserve changes.

Cursor on login: Three spots declare cursor theme (system, home-manager, greeter). Each is intentional for fallback coverage.

What's Included

niri (Wayland)
Noctalia greeter + shell
Nemo file manager
zsh + starship + fzf + zoxide
gpu-screen-recorder (HEVC)
Steam + Heroic
Chrome, LibreWolf, Zed

Aliases

ls          # eza --icons=always --group-directories-first
ll          # eza -la --icons=always --group-directories-first
reb         # rebuild + commit + push (cd to flake, git add/commit/push, nixos-rebuild)
upd         # flake update + rebuild + commit + push
gens        # nix-env list-generations --profile /nix/var/nix/profiles/system
rollback    # nixos-rebuild switch --rollback
clean       # delete old generations + garbage collect

Keybinds

Alt+Shift: Toggle US/LV keyboard layout
Shift+F12: Toggle MangoHud overlay

Customize

Theme: Wallpaper path in home.nix (Noctalia auto-derives palette)
Apps: Add/remove from home.packages
Keyboard: US+LV in configuration.nix, change layout and options
Aliases: Edit programs.zsh.shellAliases in home.nix
