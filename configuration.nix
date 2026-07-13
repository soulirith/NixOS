{ config, inputs, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    inputs.noctalia-greeter.nixosModules.default
  ];

  # Bootloader & Kernel
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;

  # System Services
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  # Time & Locale
  time.timeZone = "Europe/Riga";
  i18n.defaultLocale = "en_US.UTF-8";

  # Keymap
  services.xserver.xkb = { layout = "us"; variant = ""; };

  # Sound (Pipewire)
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # User Account
  users.users."soulirith" = {
    isNormalUser = true;
    description = "soulirith";
    extraGroups = [ "networkmanager" "wheel" "gamemode" ];
    shell = pkgs.zsh;
  };

  # Shells & Programs
  programs.zsh.enable = true;
  programs.dconf.enable = true;
  services.dbus.enable = true;

  # ZRAM
  zramSwap = {
  enable = true;
  algorithm = "zstd";
  memoryPercent = 50; 
  priority = 100;
};

  # Nix settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # Greeter Settings
  programs.noctalia-greeter = {
    enable = true;
    package = inputs.noctalia-greeter.packages.${pkgs.stdenv.hostPlatform.system}.default;
    settings = {
      cursor = { theme = "catppuccin-mocha-dark-cursors"; size = 24; };
      keyboard = { layout = "us"; };
    };
  };

  # NVIDIA Driver Settings
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
    powerManagement.enable = true;
    open = false;
    nvidiaSettings = true;
    prime = {
      offload = { enable = true; enableOffloadCmd = true; };
      nvidiaBusId = "PCI:1:0:0";
      amdgpuBusId = "PCI:5:0:0";
    };
  };
  
  boot.blacklistedKernelModules = [ "nouveau" ];
  boot.kernelParams = [ "nvidia_drm.modeset=1" "nvidia_drm.fbdev=1" "psi=1" "processor.max_cstate=1" ];  
  environment.sessionVariables = {
    "__GLX_VENDOR_LIBRARY_NAME" = "nvidia";
    "GBM_BACKEND" = "nvidia-drm";
  };
   
  # XDG Portal: Prioritizes GTK to enforce Nemo associations
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = [ "gtk" ];
  };

  nixpkgs.overlays = [
  (final: prev: {
    pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
      (pyFinal: pyPrev: {
        catppuccin = pyPrev.catppuccin.overridePythonAttrs (old: {
          doCheck = false;
        });
      })
    ];
  })
];

  nixpkgs.config.permittedInsecurePackages = [ "pnpm-10.29.2" ];
  nixpkgs.config.allowUnfree = true;
  services.flatpak.enable = true;
  services.gvfs.enable = true;
  programs.steam.enable = true;
  programs.niri.enable = true;
  programs.xwayland.enable = true;
  programs.gamemode.enable = true;
  systemd.oomd.enable = true;
  systemd.oomd.enableRootSlice = true;
  environment.systemPackages = [ pkgs.catppuccin-cursors.mochaDark ];
  system.stateVersion = "26.05";
}
