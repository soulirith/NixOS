{ config, inputs, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    inputs.noctalia-greeter.nixosModules.default
  ];

  # Boot. zen kernel for desktop latency, nouveau blacklisted so nvidia loads.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.tmp.cleanOnBoot = true;
  boot.blacklistedKernelModules = [ "nouveau" ];
  boot.kernelParams = [ "nvidia_drm.modeset=1" "nvidia_drm.fbdev=1" "psi=1" ];  # psi=1 for oomd

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;

  # Services. gvfs = trash/mounts in nautilus, fstrim = weekly SSD trim.
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  services.fstrim.enable = true;
  services.gvfs.enable = true;
  services.flatpak.enable = true;
  services.dbus.enable = true;

  # Locale & keymap
  time.timeZone = "Europe/Riga";
  i18n.defaultLocale = "en_US.UTF-8";
  services.xserver.xkb = { layout = "us"; variant = ""; };

  # Audio. Pipewire replaces pulse, 32-bit alsa for Steam.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # User
  users.users."soulirith" = {
    isNormalUser = true;
    description = "soulirith";
    extraGroups = [ "networkmanager" "wheel" "gamemode" ];
    shell = pkgs.zsh;
  };

  # Session. OZONE_WL makes Electron apps run native Wayland.
  programs.niri.enable = true;
  programs.xwayland.enable = true;
  programs.zsh.enable = true;
  programs.dconf.enable = true;
  programs.steam.enable = true;
  programs.gamemode.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Login screen
  programs.noctalia-greeter = {
    enable = true;
    package = inputs.noctalia-greeter.packages.${pkgs.stdenv.hostPlatform.system}.default;
    settings = {
      cursor = { theme = "catppuccin-mocha-dark-cursors"; size = 24; };
    };
  };

  # Fallback fonts (CJK + emoji coverage)
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  # Memory. zram over disk swap, oomd kills before the system locks up.
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };
  systemd.oomd.enable = true;
  systemd.oomd.enableRootSlice = true;

  # NVIDIA. Prime offload: iGPU by default, `nvidia-offload <cmd>` for dGPU.
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
    powerManagement = {
      enable = true;
      finegrained = true;  # powers dGPU down when idle
    };
    open = false;
    nvidiaSettings = true;
    prime = {
      offload = { enable = true; enableOffloadCmd = true; };
      nvidiaBusId = "PCI:1:0:0";
      amdgpuBusId = "PCI:5:0:0";
    };
  };

  # Nix. cores=0 means use all, weekly GC of anything older than 7d.
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    max-jobs = "auto";
    cores = 0;
    substituters = [ "https://cache.nixos.org" "https://nix-community.cachix.org" ];
    trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [ "pnpm-10.29.2" ];

  # System-wide so the greeter can find the cursor before login
  environment.systemPackages = with pkgs; [
    catppuccin-cursors.mochaDark
  ];

  system.stateVersion = "26.05";
}
