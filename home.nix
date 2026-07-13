{ config, pkgs, inputs, ... }:
{
  home.username = "soulirith";
  home.homeDirectory = "/home/soulirith";
  home.stateVersion = "26.05";
  imports = [
    inputs.catppuccin.homeModules.catppuccin
    inputs.noctalia.homeModules.default
    inputs.spicetify-nix.homeManagerModules.default
  ];

  # Noctalia Home Manager Configuration
  programs.noctalia = {
    enable = true;
    settings = {
      theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Catppuccin";
      };
      wallpaper = {
        enabled = true;
        default.path = "/home/soulirith/Pictures/wallpaper.png";
        backdrop = {
          enabled = true;
          blur_intensity = 1;
          tint_intensity = 0.1;
        };
      };
    };
  };

  # Catppuccin theming (applies to any enabled program it supports: kitty, btop, bat, fzf, starship, etc.)
  catppuccin = {
    enable = true;
    autoEnable = true;
    flavor = "mocha";
    accent = "mauve";
  };
  gtk = {
    enable = true;
    theme = {
      name = "Catppuccin-Mocha-Standard-Mauve-Dark";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "mauve" ];
        variant = "mocha";
      };
    };
    cursorTheme = {
      package = pkgs.catppuccin-cursors.mochaDark;
      name = "catppuccin-mocha-dark-cursors";
      size = 24;
    };
  };

  # MIME Associations: Explicitly sets Nautilus as the default for directories
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = "org.gnome.Nautilus.desktop";
    };
  };

  #  ZSH config, aliases, bat replacement
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ls = "eza --icons=always --group-directories-first";
      ll = "eza -la --icons=always --group-directories-first";
      cat = "bat";
    };
    initContent = ''
      fastfetch
      alias reb='(cd /etc/nixos && git add . && git commit -m "rebuild: $(date +%Y-%m-%d\ %H:%M)" && git push && sudo nixos-rebuild switch --flake .)'
      alias upd='(cd /etc/nixos && nix flake update && git add . && git commit -m "flake update: $(date +%Y-%m-%d\ %H:%M)" && git push && sudo nixos-rebuild switch --flake .)'
      alias clean='(cd /etc/nixos && sudo nix-env --delete-generations +2 --profile /nix/var/nix/profiles/system && sudo nix-store --gc)'
      alias gens='sudo nix-env --list-generations --profile /nix/var/nix/profiles/system'
      alias rollback='sudo nixos-rebuild switch --flake /etc/nixos#nixos --rollback'
    '';
  };

  # Prompt, fuzzy search, monitoring, cat replacement
    programs.starship = {
    enable = true;
    settings = {
      palette = "catppuccin_mocha";
      right_format = "$time";
      time = {
        disabled = false;
        format = "[$time]($style) ";
      };
    };
  };
  programs.bat.enable = true;
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # Zoxide, Kitty, and Cursor settings
  programs.zoxide = { enable = true; enableZshIntegration = true; };
  programs.kitty = {
    enable = true;
    settings = {
      confirm_os_window_close = 0;
      font_family = "JetBrainsMono Nerd Font";
      font_size = "10.0";
      background_opacity = "0.3";
      background_blur = "1";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
    };
  };

  # Spotify
  programs.spicetify =
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in {
      enable = true;
      theme = spicePkgs.themes.catppuccin;
      colorScheme = "mocha";
      enabledExtensions = with spicePkgs.extensions; [
        adblock
        hidePodcasts
      ];
    };

  # Cursor
  home.pointerCursor = {
    enable = true;
    name = "catppuccin-mocha-dark-cursors";
    package = pkgs.catppuccin-cursors.mochaDark;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  # User Packages
  home.packages = with pkgs; [
    wget google-chrome discord git kitty fastfetch pciutils file-roller
    zoxide eza heroic xwayland-satellite prismlauncher gamemode nautilus gnome-text-editor
    nerd-fonts.jetbrains-mono modrinth-app vinegar
    nodejs_22
    mangohud btop zellij
  ];

  programs.home-manager.enable = true;
}
