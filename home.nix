{ config, pkgs, inputs, lib, ... }:
{
  home.username = "soulirith";
  home.homeDirectory = "/home/soulirith";
  home.stateVersion = "26.05";

  imports = [];

  stylix = {
    enable = true;
    image = ./Pictures/Wallpaper/wallhaven-yqk2q7.jpg;
    polarity = "dark";
    
    cursor = {
      name = "catppuccin-mocha-dark-cursors";
      package = pkgs.catppuccin-cursors.mochaDark;
      size = 24;
    };

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };
      sizes = {
        applications = 11;
        terminal = 12;
        desktop = 11;
        popups = 12;
      };
    };
    
    targets.btop.enable = false;
    targets.cava.enable = false;
    targets.gtk.enable = false;
    targets.kitty.enable = false;
    targets.qt.enable = false;
    targets.starship.enable = false;
    targets.neovim.enable = true;
  };

  # Environment Variables
  home.sessionVariables = {
    XDG_CURRENT_DESKTOP = "X-Cinnamon";
  };

  # Noctalia
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

  # Browser MIME associations
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = "nemo.desktop";
      "x-scheme-handler/http" = "google-chrome.desktop";
      "x-scheme-handler/https" = "google-chrome.desktop";
      "x-scheme-handler/about" = "google-chrome.desktop";
      "x-scheme-handler/unknown" = "google-chrome.desktop";
      "text/html" = "google-chrome.desktop";
    };
  };

  # Neovim configuration
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
      colorscheme base16-default-dark
    '';
  };

  # GTK configurations
  xdg.configFile."gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-icon-theme-name=Papirus-Dark
    gtk-application-prefer-dark-theme=1
  '';

  # Zsh Configuration Block
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    autosuggestion.highlight = "fg=#8899aa";
    shellAliases = {
      ls = "eza --icons=always --group-directories-first";
      ll = "eza -la --icons=always --group-directories-first";
      gens = "doas nix-env --list-generations --profile /nix/var/nix/profiles/system";
      rollback = "doas nixos-rebuild switch --flake /etc/nixos#nixos --rollback";
      clean = "(cd /etc/nixos && doas nix-env --delete-generations +2 --profile /nix/var/nix/profiles/system && doas nix-store --gc)";
    };

    initContent = ''
      fastfetch
      alias reb="(cd /etc/nixos && git add -A && doas nixos-rebuild switch --flake . && (git diff --cached --quiet || git commit -m \"rebuild: \$(date +%Y-%m-%d\ %H:%M)\") && git push)"
      alias upd="(cd /etc/nixos && nix flake update && git add -A && doas nixos-rebuild switch --flake . && (git diff --cached --quiet || git commit -m \"flake update: \$(date +%Y-%m-%d\ %H:%M)\") && git push)"
      eval "$(starship init zsh)"
    '';
  };

  # CLI Utilities Integration
  programs.fzf = { enable = true; enableZshIntegration = true; };
  programs.zoxide = { enable = true; enableZshIntegration = true; };

  # MPV
  programs.mpv = {
    enable = true;
    config = {
      hwdec = "auto-safe";
      vo = "gpu-next";
      video-sync = "display-resample";
    };
  };

  # MangoHUD
  xdg.configFile."MangoHud/MangoHud.conf".text = ''
    legacy_layout=0
    no_display=0
    position=top-left
    font_size=14
    fps
    fps_color_change
    frame_timing
    gpu_color=ff9e7d
    background_alpha=0
    text_outline
    toggle_hud=Shift_R+F12
  '';

  # Fastfetch
  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        source = "NixOS_small";
        padding = { top = 1; };
      };
      display = {
        separator = "  ";
        key = { type = "icon"; };
      };
      modules = [
        { type = "os"; }
        { type = "kernel"; }
        { type = "wm"; }
        { type = "shell"; }
        { type = "terminal"; }
        { type = "cpu"; }
        { type = "gpu"; }
        { type = "memory"; }
        { type = "disk"; }
        { type = "packages"; }
        { type = "battery"; }
        { type = "uptime"; }
      ];
    };
  };

  # Home packages
  home.packages = with pkgs; [
    librewolf google-chrome wl-clipboard
    kitty git wget eza pciutils
    nemo ffmpegthumbnailer unimatrix btop pipes
    zed-editor nodejs_22 gpu-screen-recorder
    heroic prismlauncher mangohud vinegar smartmontools easyeffects
    vesktop xwayland-satellite starship mpvpaper keepassxc yt-dlp
    adw-gtk3 papirus-icon-theme motrix-next file-roller nemo-fileroller
    xdg-desktop-portal-xapp sonixd 
  ];

  programs.home-manager.enable = true;
}
