{ config, pkgs, inputs, ... }:
{
  home.username = "soulirith";
  home.homeDirectory = "/home/soulirith";
  home.stateVersion = "26.05";

  imports = [
    inputs.noctalia.homeModules.default
    inputs.spicetify-nix.homeManagerModules.default
  ];

  # Shell/panel. Owns GTK/Qt/Niri theming, palette set in its GUI.
  programs.noctalia = {
    enable = true;
    settings = {
      theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Catppuccin";
      };

      shell = {
        polkit_agent = true;              # needed for greeter sync prompts
        password_style = "random";
        panel.transparency_mode = "glass";
        greeter_sync.auto_sync = true;
      };

      wallpaper = {
        enabled = true;
        default.path = "/home/soulirith/Pictures/";
        };
      };
    };

   # MIME association
   xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = "nemo.desktop";
    };
  };

   # libdecor reads the theme from here, fastfetch reads the cursor
  xdg.configFile."gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name=adw-gtk3-dark
    gtk-icon-theme-name=Papirus-Dark
    gtk-cursor-theme-name=catppuccin-mocha-dark-cursors
    gtk-cursor-theme-size=24
    gtk-application-prefer-dark-theme=1
  '';

  # Cursor
  home.pointerCursor = {
    enable = true;
    name = "catppuccin-mocha-dark-cursors";
    package = pkgs.catppuccin-cursors.mochaDark;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  # Shell
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
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
      alias reb='(cd /etc/nixos && git add . && git commit -m "rebuild: $(date +%Y-%m-%d\ %H:%M)" && git push && doas nixos-rebuild switch --flake .)'
      alias upd='(cd /etc/nixos && nix flake update && git add . && git commit -m "flake update: $(date +%Y-%m-%d\ %H:%M)" && git push && doas nixos-rebuild switch --flake .)'
    '';
  };

  # Prompt
  programs.starship = {
    enable = true;
    settings = {
      right_format = "$time";
      time = {
        disabled = false;
        format = "[$time]($style) ";
      };
    };
  };

  programs.fzf = { enable = true; enableZshIntegration = true; };
  programs.zoxide = { enable = true; enableZshIntegration = true; };

  # Terminal
  programs.kitty = {
    enable = true;
    settings = {
      confirm_os_window_close = 0;
      font_family = "JetBrainsMono Nerd Font";
      font_size = "10.0";
      background_opacity = "0.35";
      background_blur = "1";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      window_padding_width = 16;
    };
  };

  # Spotify. Flags force native Wayland (no XWayland titlebar).
  programs.spicetify =
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in {
      enable = true;
      enabledExtensions = with spicePkgs.extensions; [
        adblock
        hidePodcasts
      ];
    };

  # Game overlay, Shift_R+F12
    xdg.configFile."MangoHud/MangoHud.conf".text = ''
    legacy_layout=0

    round_corners=10
    background_alpha=0.4
    position=top-left
    font_size=20
    background_color=1e1e2e
    text_color=cdd6f4

    fps
    fps_color_change
    frame_timing

    gpu_color=f38ba8
    text_outline

    toggle_hud=Shift_R+F12
    no_display=0
  '';

  # Fetch on shell start
  xdg.configFile."fastfetch/config.jsonc".text = builtins.toJSON {
        logo = {
      source = "/home/soulirith/Pictures/nixos-logo.png";
      type = "kitty-direct";
      height = 15;
      padding.top = 1;
    };
    display.key.type = "both";
    modules = [
      { type = "title"; color = { user = "#89b4fa"; at = "#6c7086"; host = "#cba6f7"; }; }
      { type = "custom"; format = "{#magenta}────────────────────────────────{#}"; }
      { type = "os"; keyColor = "#cba6f7"; }
      { type = "kernel"; keyColor = "#cba6f7"; }
      { type = "packages"; keyColor = "#cba6f7"; }
      { type = "display"; keyColor = "#cba6f7"; }
      { type = "wm"; keyColor = "#cba6f7"; }
      { type = "terminal"; keyColor = "#cba6f7"; }
      { type = "terminalfont"; keyColor = "#cba6f7"; }
      { type = "cursor"; keyColor = "#cba6f7"; }
      { type = "custom"; format = "{#blue}────────────────────────────────{#}"; }
      { type = "cpu"; keyColor = "#89b4fa"; }
      { type = "gpu"; keyColor = "#89b4fa"; }
      { type = "memory"; keyColor = "#89b4fa"; }
      { type = "disk"; keyColor = "#89b4fa"; }
      { type = "uptime"; keyColor = "#89b4fa"; }
      "break"
      { type = "colors"; symbol = "circle"; }
    ];
  };

  home.packages = with pkgs; [
    librewolf google-chrome
    kitty git wget eza zoxide fastfetch pciutils
    nemo ffmpegthumbnailer                     
    zed-editor nodejs_22 gpu-screen-recorder mpv
    heroic prismlauncher modrinth-app mangohud vinegar mangohud
    vesktop qpwgraph xwayland-satellite
    nerd-fonts.jetbrains-mono adw-gtk3 papirus-icon-theme
  ];

  programs.home-manager.enable = true;
}

