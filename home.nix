{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    ./terminal.nix
  ];

  home.username = "soulirith";
  home.homeDirectory = "/home/soulirith";
  home.stateVersion = "26.05";

  # Fonts Configuration
  fonts.fontconfig.enable = true;

  # Explicit Cursor Configuration for GTK & Wayland
  home.pointerCursor = {
    enable = true;
    name = "catppuccin-mocha-dark-cursors";
    package = pkgs.catppuccin-cursors.mochaDark;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  gtk = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 10;
    };
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "catppuccin-mocha-dark-cursors";
      package = pkgs.catppuccin-cursors.mochaDark;
      size = 24;
    };
  };

  # Noctalia Desktop Shell Configuration
  programs.noctalia = {
    enable = true;
    settings = {
      shell = {
        polkit_agent = true;
        password_style = "random";
        panel.transparency_mode = "glass";
        greeter_sync.auto_sync = true;
      };
    };
  };

  # Force Nemo to ALWAYS handle all directory and folder opening actions
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = [ "nemo.desktop" ];
      "application/x-directory" = [ "nemo.desktop" ];
      "folder" = [ "nemo.desktop" ];
      "x-scheme-handler/http" = [ "google-chrome.desktop" ];
      "x-scheme-handler/https" = [ "google-chrome.desktop" ];
      "x-scheme-handler/about" = [ "google-chrome.desktop" ];
      "x-scheme-handler/unknown" = [ "google-chrome.desktop" ];
      "text/html" = [ "google-chrome.desktop" ];
      "x-scheme-handler/roblox-studio" = [ "tuxblox-studio-handler.desktop" ];
      "x-scheme-handler/roblox-studio-auth" = [ "tuxblox-studio-handler.desktop" ];
      "x-scheme-handler/roblox-auth" = [ "tuxblox-studio-handler.desktop" ];
      "x-scheme-handler/roblox-player" = [ "tuxblox-player-handler.desktop" ];
      "x-scheme-handler/roblox" = [ "tuxblox-player-handler.desktop" ];
    };
  };

  # Neovim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      base16-nvim
    ];
    extraConfig = ''
      set clipboard+=unnamedplus
      set termguicolors
    '';
  };

  # Direct GTK Styling Rules
  xdg.configFile."gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-icon-theme-name=Papirus-Dark
    gtk-theme-name=adw-gtk3-dark
    gtk-cursor-theme-name=Catppuccin-Mocha-Dark-Cursors
    gtk-cursor-theme-size=24
    gtk-application-prefer-dark-theme=1
  '';

  # Media Players
  programs.mpv = {
    enable = true;
    config = {
      hwdec = "auto-safe";
      vo = "gpu-next";
      video-sync = "display-resample";
    };
  };

  # Packages
  home.packages = with pkgs; [
    librewolf
    google-chrome
    wl-clipboard
    git
    wget
    eza
    pciutils
    nemo
    ffmpegthumbnailer
    unimatrix
    btop
    pipes
    zed-editor
    nodejs_22
    lutris
    prismlauncher
    smartmontools
    easyeffects
    vesktop
    xwayland-satellite
    mpvpaper
    keepassxc
    yt-dlp
    adw-gtk3
    papirus-icon-theme
    file-roller
    nemo-fileroller
    xdg-desktop-portal-xapp
    obsidian
    steam-run
    vinegar
    vscodium
    spotube
    microfetch
    inputs.claude-desktop.packages.${pkgs.system}.claude-desktop-fhs
    inputs.blender-bin.packages.${pkgs.system}.default
  ];

  programs.home-manager.enable = true;
}

