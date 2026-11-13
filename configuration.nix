{ config, inputs, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Boot & Kernel Configuration
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages;
    tmp.cleanOnBoot = true;
    blacklistedKernelModules = [ "nouveau" ];
    kernelParams = [
      "nvidia_drm.modeset=1"
      "nvidia_drm.fbdev=1"
      "psi=1"
      "nvme_core.default_ps_max_latency_us=0"
      "iomem=relaxed"
      "pcie_port_pm=force"
    ];
  };

  # Networking & Hostname
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    extraHosts = ''
      0.0.0.0 battleye.com
    '';
  };

  hardware.bluetooth.enable = true;

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
  };

  # Power Management & Thermal Handling
  services.power-profiles-daemon.enable = false;
  services.thermald.enable = false; # Disabled: thermald is Intel-only
  
  # Logind Handling
  services.logind.settings.Login = {
    HandlePowerKey = "suspend";
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
  };

  # System Services
  services.upower.enable = true;
  services.fstrim.enable = true;
  services.gvfs.enable = true;
  services.flatpak.enable = true;
  services.dbus.enable = true;

  # Ollama Service (Disabled auto-start so GPU can sleep; run `doas systemctl start ollama` when needed)
  services.ollama = {
    enable = true;
    package = pkgs.ollama-vulkan;
  };

  # Localization & Keyboard
  time.timeZone = "Europe/Riga";
  i18n.defaultLocale = "en_US.UTF-8";
  services.xserver.xkb = {
    layout = "us,lv";
    variant = "";
    options = "grp:alt_shift_toggle";
  };

  # Audio (PipeWire)
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Desktop Integration Portals
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

  # Security & Privilege Escalation (doas)
  security.sudo.enable = false;
  security.doas = {
    enable = true;
    extraRules = [
      {
        users = [ "soulirith" ];
        keepEnv = true;
        persist = true;
      }
      {
        users = [ "soulirith" ];
        cmd = "${pkgs.ryzenadj}/bin/ryzenadj";
        noPass = true;
      }
      {
        users = [ "soulirith" ];
        cmd = "${pkgs.linuxPackages.cpupower}/bin/cpupower";
        noPass = true;
      }
    ];
  };

  # User Account
  users.users.soulirith = {
    isNormalUser = true;
    description = "soulirith";
    extraGroups = [ "networkmanager" "wheel" "gamemode" "libvirtd" "ollama" ];
    shell = pkgs.fish;
  };

  # Desktop Environment & Program Flags
  programs.niri.enable = true;
  programs.xwayland.enable = true;
  programs.fish.enable = true;
  programs.dconf.enable = true;
  programs.steam.enable = true;
  programs.gamemode.enable = true;
  programs.gpu-screen-recorder.enable = true;
  programs.gpu-screen-recorder.ui.enable = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    XCURSOR_THEME = "Catppuccin-Mocha-Dark-Cursors";
    XCURSOR_SIZE = "24";
    HYPRCURSOR_THEME = "catppuccin-mocha-dark-cursors";
    HYPRCURSOR_SIZE = "24";
  };

  services.displayManager.noctalia-greeter = {
    enable = true;
    settings = {
      cursor.size = 24;
      keyboard.layout = "us";
    };
    cursorTheme = {
      package = pkgs.catppuccin-cursors.mochaDark;
      name = "Catppuccin-Mocha-Dark-Cursors";
    };
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    jetbrains-mono
    nerd-fonts.jetbrains-mono
  ];

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };
  systemd.oomd.enable = true;
  systemd.oomd.enableRootSlice = true;

  # Graphics & GPU Offloading (PRIME Dynamic Power Management)
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true; 
    powerManagement = {
      enable = true;
      finegrained = true; # Autosuspend GPU when unneeded
    };
    open = false;
    nvidiaSettings = true;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      nvidiaBusId = "PCI:1:0:0";
      amdgpuBusId = "PCI:5:0:0";
    };
  };

  environment.systemPackages = with pkgs; [
    catppuccin-cursors.mochaDark
    git
    lm_sensors
    nvtopPackages.full
    xdg-desktop-portal-xapp
    cudaPackages.cudatoolkit
    ryzenadj
    linuxPackages.cpupower

    (writeShellScriptBin "nvidia-offload" ''
      export __NV_PRIME_RENDER_OFFLOAD=1
      export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export __GL_MAX_ERRORS_TO_REPORT=1
      exec "$@"
    '')

    (writeShellScriptBin "mode-quiet" ''
      echo "Activating Quiet Profile..."
      doas ${pkgs.ryzenadj}/bin/ryzenadj --tctl-temp=55 --fast-limit=10000 --slow-limit=8000
      doas ${pkgs.linuxPackages.cpupower}/bin/cpupower frequency-set -g powersave
      doas sh -c "echo 0 > /sys/devices/system/cpu/cpufreq/boost"
      echo "System locked to silent baseline (55°C Cap | No Boost | 10W TDP)."
    '')

    (writeShellScriptBin "mode-perf" ''
      echo "Activating Performance Profile..."
      doas sh -c "echo 1 > /sys/devices/system/cpu/cpufreq/boost"
      doas ${pkgs.linuxPackages.cpupower}/bin/cpupower frequency-set -g performance
      doas ${pkgs.ryzenadj}/bin/ryzenadj --tctl-temp=75 --fast-limit=45000 --slow-limit=35000
      echo "Max performance unlocked (75°C Quiet Cap | Boost Enabled | 45W TDP)."
    '')
  ];

  # Nix Package Manager Settings
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      max-jobs = "auto";
      cores = 0;
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://noctalia.cachix.org"
        "https://umbriel.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
        "umbriel.cachix.org-1:JfNq/2yg2S6D6z4Z2dVSZrZlDPQTKtexB6GAVLD98nw="
      ];
      trusted-users = [ "root" "soulirith" ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
    allowUnsupportedSystem = true;
  };

  system.stateVersion = "26.05";
}
