{ config, pkgs, inputs, lib, ... }:

{
  home.username = "soulirith";
  home.homeDirectory = "/home/soulirith";
  home.stateVersion = "26.05";

  # Fonts Configuration
  fonts.fontconfig.enable = true;

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

  # Native GTK & Icon Theme Configuration
  gtk = {
    enable = true;
    font.name = "JetBrainsMono Nerd Font 10";
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
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = [ "nemo.desktop" ];
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
    gtk-application-prefer-dark-theme=1
  '';

  # Shell Configuration (Zsh)
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion = {
      enable = true;
      highlight = "fg=#8899aa";
    };
    syntaxHighlighting.enable = true;

    shellAliases = {
      ls = "eza --icons=always --group-directories-first";
      ll = "eza -la --icons=always --group-directories-first";
      gens = "doas nix-env --list-generations --profile /nix/var/nix/profiles/system";
      rollback = "doas nixos-rebuild switch --flake /etc/nixos#nixos --rollback";
      clean = "(cd /etc/nixos && doas nix-env --delete-generations +2 --profile /nix/var/nix/profiles/system && doas nix-store --gc)";
    };

    initContent = ''
      fastfetch
      alias reb="(cd /etc/nixos && git add -A && doas nixos-rebuild switch --flake .#nixos && (git diff --cached --quiet || git commit -m \"rebuild: \$(date +%Y-%m-%d\ %H:%M)\") && git push)"
      alias upd="(cd /etc/nixos && nix flake update && git add -A && doas nixos-rebuild switch --flake .#nixos && (git diff --cached --quiet || git commit -m \"flake update: \$(date +%Y-%m-%d\ %H:%M)\") && git push)"
      eval "$(starship init zsh)"
    '';
  };

  # CLI Helpers Integration
  programs.fzf = { enable = true; enableZshIntegration = true; };
  programs.zoxide = { enable = true; enableZshIntegration = true; };

  # Media Players
  programs.mpv = {
    enable = true;
    config = {
      hwdec = "auto-safe";
      vo = "gpu-next";
      video-sync = "display-resample";
    };
  };

  programs.mangohud = {
    enable = false;
    enableSessionWide = false;
  };

# Fastfetch Configuration
  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        type = "auto";
        source = "nixos_small";
        padding = {
          top = 1;
          left = 2;
          right = 2;
        };
      };
      display = {
        separator = " ";
      };
      modules = [
        "title"
        "separator"
        { type = "os"; key = "󰍹"; }
        { type = "kernel"; key = "󰒋"; }
        { type = "uptime"; key = "󰅐"; }
        { type = "packages"; key = "󰏖"; }
        { type = "wm"; key = "󱂬"; }
        { type = "shell"; key = "󰞷"; }
        { type = "terminal"; key = "󰆍"; }
        { type = "cpu"; key = "󰻠"; }
        { type = "gpu"; key = "󰢮"; }
        { type = "memory"; key = "󰍛"; }
        { type = "disk"; key = "󰋊"; }
        { type = "battery"; key = "󰁹"; }
      ];
    };
  };

  # Packages
  home.packages = with pkgs; [
    librewolf
    google-chrome
    wl-clipboard
    kitty
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
    starship
    mpvpaper
    keepassxc
    yt-dlp
    adw-gtk3
    papirus-icon-theme
    rayburst
    file-roller
    nemo-fileroller
    xdg-desktop-portal-xapp
    sonixd
    obsidian
    steam-run
    vinegar
    jetbrains-mono
    nerd-fonts.jetbrains-mono
    inputs.claude-desktop.packages.${pkgs.system}.claude-desktop-fhs
    inputs.blender-bin.packages.${pkgs.system}.default
  ];

  programs.home-manager.enable = true;
}
