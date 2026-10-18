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
    ];
  };

  # Networking & Hostname
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    extraHosts = ''
      0.0.0.0 ://battleye.com
      0.0.0.0 ://battleye.com
      0.0.0.0 ://battleye.com
    '';
  };

  hardware.bluetooth.enable = false;

  # Power Management & Lid Handling
  services.power-profiles-daemon.enable = false;
  services.thermald.enable = true;
  services.auto-cpufreq = {
    enable = true;
    settings = {
      charger = {
        governor = "performance";
        turbo = "auto";
        # Instructs the system firmware to keep voltage lanes open for the GPU
        platform_profile = "performance";
      };
      battery = {
        governor = "performance"; # Prioritize performance even if unplugged
        turbo = "auto";
        platform_profile = "performance";
      };
    };
  };

  # Ignore physical lid switch events so Niri / Noctalia handles lock-and-suspend
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
  };

  # System Services
  services.upower.enable = true;
  services.fstrim.enable = true;
  services.gvfs.enable = true;
  services.flatpak.enable = true;
  services.dbus.enable = true;

  # Thermal Limit Service (CPU)
  # Lowered to 75C to prevent your single core from running hot and making your fans loud
  systemd.services.ryzenadj-limit = {
    description = "Set Ryzen CPU thermal limit to 75C for quiet acoustics";
    after = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.ryzenadj}/bin/ryzenadj --tctl-temp=75";
    };
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

  # User Account
  users.users.soulirith = {
    isNormalUser = true;
    description = "soulirith";
    extraGroups = [ "networkmanager" "wheel" "gamemode" "libvirtd" ];
    shell = pkgs.zsh;
  };

  # Desktop Environment & Program Flags
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

  # Display Manager / Noctalia Greeter
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

  # Typography
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  # Memory & OOM Management
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };
  systemd.oomd.enable = true;
  systemd.oomd.enableRootSlice = true;

  # Graphics & GPU Offloading (NVIDIA / AMD)
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
    dynamicBoost.enable = true;
    powerManagement = {
      enable = false; # Keeps GPU out of aggressive power-saving sleep loops
      finegrained = false;
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

  # System Tools
  environment.systemPackages = with pkgs; [
    catppuccin-cursors.mochaDark
    git
    lm_sensors
    nvtopPackages.full
    ryzenadj
    xdg-desktop-portal-xapp

    # Fixed script: Removed the strict optimus layer that caused driver fallback loops
    (writeShellScriptBin "nvidia-offload" ''
      export __NV_PRIME_RENDER_OFFLOAD=1
      export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export __GL_MAX_ERRORS_TO_REPORT=1
      exec "$@"
    '')
  ];

  # Nix Package Manager & Cache Configuration
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      max-jobs = "auto";
      cores = 0;
      substituters = [
        "https://nixos.org"
        "https://cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      ];
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

