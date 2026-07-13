{ config, pkgs, inputs, ... }:

{
  home.username = "soulirith";
  home.homeDirectory = "/home/soulirith";
  home.stateVersion = "26.05";

  imports = [
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
    blur_intensity = 0.5;
    tint_intensity = 0.3;
      };
    };
  };
};
  # Theme Configuration: Forces Catppuccin GTK/Icons for apps like Nemo
  gtk = {
    enable = true;
    theme = {
      name = "Catppuccin-Mocha-Standard-Mauve-Dark";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "mauve" ];
        variant = "mocha";
      };
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
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
  
  # Zsh Configuration
programs.zsh = {
  enable = true;
  enableCompletion = true;
  autosuggestion.enable = true;
  syntaxHighlighting.enable = true;
  shellAliases = {
    ls = "eza --icons=always --group-directories-first";
    ll = "eza -la --icons=always --group-directories-first";
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

  # Zoxide, Kitty, and Cursor settings
  programs.zoxide = { enable = true; enableZshIntegration = true; };
  programs.kitty = {
    enable = true;
    settings = {
      confirm_os_window_close = 0;
      font_family = "JetBrainsMono Nerd Font";
      font_size = "10.0";
      background_opacity = "0.7";
      background_blur = "1";
     };
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
 ];

  programs.home-manager.enable = true;
}
