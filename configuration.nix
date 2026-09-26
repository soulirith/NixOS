{ config, inputs, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages;
  boot.tmp.cleanOnBoot = true;
  boot.blacklistedKernelModules = [ "nouveau" ];
  boot.kernelParams = [ "nvidia_drm.modeset=1" "nvidia_drm.fbdev=1" "psi=1" "nvme_core.default_ps_max_latency_us=0" ];

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = false;

  # Thermal and Power Management
  services.power-profiles-daemon.enable = false;
  services.thermald.enable = true;
  services.auto-cpufreq = {
    enable = true;
    settings = {
      charger = {
        governor = "performance";
        turbo = "auto";
      };
      battery = {
        governor = "powersave";
        turbo = "never";
      };
    };
  };

  # Services
  services.upower.enable = true;
  services.fstrim.enable = true;
  services.gvfs.enable = true;
  services.flatpak.enable = true;
  services.dbus.enable = true;

  # Locale
  time.timeZone = "Europe/Riga";
  i18n.defaultLocale = "en_US.UTF-8";
  services.xserver.xkb = {
    layout = "us,lv";
    variant = "";
    options = "grp:alt_shift_toggle";
  };

  # Audio
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # XDG Portal
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-xapp
    ];
    config.common = {
      default = [ "gtk" "wlr" ];
      "org.freedesktop.impl.portal.FileChooser" = [ "xapp" ];
    };
  };

  # doas replaces sudo
  security.sudo.enable = false;
  security.doas = {
    enable = true;
    extraRules = [{
      users = [ "soulirith" ];
      keepEnv = true;
      persist = true;
    }];
  };

  security.wrappers.gsr-kms-server = {
    source = "${pkgs.gpu-screen-recorder}/bin/gsr-kms-server";
    capabilities = "cap_sys_admin+ep";
    owner = "root";
    group = "root";
  };

  # User
  users.users."soulirith" = {
    isNormalUser = true;
    description = "soulirith";
    extraGroups = [ "networkmanager" "wheel" "gamemode" "libvirtd" ];
    shell = pkgs.zsh;
  };

  # Session
  programs.niri.enable = true;
  programs.xwayland.enable = true;
  programs.zsh.enable = true;
  programs.dconf.enable = true;
  programs.steam.enable = true;
  programs.gamemode.enable = true;
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    XCURSOR_THEME = "catppuccin-mocha-dark-cursors";
    XCURSOR_SIZE = "24";
  };

  # SDDM fallback and noctalia greeter
  services.displayManager.sddm.enable = false;
  services.displayManager.sddm.wayland.enable = false;

  # Noctalia greeter
  services.displayManager.noctalia-greeter = {
    enable = true;
    settings = {
      cursor.size = 24;
      keyboard.layout = "us";
    };
    cursorTheme = {
      package = pkgs.catppuccin-cursors.mochaDark;
      name = "catppuccin-mocha-dark-cursors";
    };
  };

  # Fonts (CJK + emoji fallback)
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  # Memory
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };
  systemd.oomd.enable = true;
  systemd.oomd.enableRootSlice = true;

  # NVIDIA. Prime offload: iGPU default, `nvidia-offload <cmd>` for dGPU.
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics.enable = true;
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
    dynamicBoost.enable = true;

    powerManagement = {
      enable = true;
      finegrained = true;
    };
    open = false;
    nvidiaSettings = true;
    prime = {
      offload = { enable = true; enableOffloadCmd = true; };
      nvidiaBusId = "PCI:1:0:0";
      amdgpuBusId = "PCI:5:0:0";
    };
  };

  # System-wide packages
  environment.systemPackages = with pkgs; [
    catppuccin-cursors.mochaDark
    git
    lm_sensors
    nvtopPackages.full
    ryzenadj
  ];

  # Nix
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    max-jobs = "auto";
    cores = 0;
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://noctalia.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nixpkgs.config = {
    allowUnfree = true;
    allowUnsupportedSystem = true;
  };

  system.stateVersion = "26.05";
}
