{ config, pkgs, inputs, ... }:
{
  home.username = "soulirith";
  home.homeDirectory = "/home/soulirith";
  home.stateVersion = "26.05";

  imports = [
    inputs.noctalia.homeModules.default
    inputs.spicetify-nix.homeManagerModules.default
  ];

  programs.noctalia = {
    enable = true;
    settings = {
      shell = {
        polkit_agent = true;
        password_style = "random";
        panel.transparency_mode = "glass";
        greeter_sync.auto_sync = true;
      };

      wallpaper = {
        enabled = true;
        default.path = "/home/soulirith/Pictures/fuji-sunset.jpg";
      };
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = "nemo.desktop";
    };
  };

  xdg.configFile."gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name=adw-gtk3-dark
    gtk-icon-theme-name=Papirus-Dark
    gtk-cursor-theme-name=catppuccin-mocha-dark-cursors
    gtk-cursor-theme-size=24
    gtk-application-prefer-dark-theme=1
  '';

    xdg.configFile."starship.toml".text = ''
    palette = "noctalia"
    right_format = "$time"
    [time]
    disabled = false
    format = "[$time]($style) "
  '';

  xdg.configFile."kitty/kitty.conf".text = ''
    include themes/noctalia.conf
    confirm_os_window_close 0
    font_family JetBrainsMono Nerd Font
    font_size 10.0
    background_opacity 0.45
    background_blur 1
    tab_bar_style powerline
    tab_powerline_style slanted
    window_padding_width 16
    allow_remote_control socket-only
    listen_on unix:/tmp/kitty
  '';

  home.pointerCursor = {
    enable = true;
    name = "catppuccin-mocha-dark-cursors";
    package = pkgs.catppuccin-cursors.mochaDark;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

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

  programs.fzf = { enable = true; enableZshIntegration = true; };
  programs.zoxide = { enable = true; enableZshIntegration = true; };

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

  xdg.configFile."MangoHud/MangoHud.conf".text = ''
    legacy_layout=0

    round_corners=10
    background_alpha=0.4
    position=top-left
    font_size=20
    background_color=2b1a17
    text_color=ffe8d6

    fps
    fps_color_change
    frame_timing

    gpu_color=ff9e7d
    text_outline

    toggle_hud=Shift_R+F12
    no_display=0
  '';

  xdg.configFile."fastfetch/config.jsonc".text = builtins.toJSON {
    logo = {
      padding.top = 1;
      height = 12;
    };
    display.key.type = "both";
    modules = [
      { type = "title"; color = { user = "#ffc98b"; at = "#8a7566"; host = "#ff9e7d"; }; }
      { type = "custom"; format = "{#208}────────────────────────────────{#}"; }
      { type = "os"; keyColor = "#ff9e7d"; }
      { type = "kernel"; keyColor = "#ff9e7d"; }
      { type = "packages"; keyColor = "#ff9e7d"; }
      { type = "display"; keyColor = "#ff9e7d"; }
      { type = "wm"; keyColor = "#ff9e7d"; }
      { type = "terminal"; keyColor = "#ff9e7d"; }
      { type = "terminalfont"; keyColor = "#ff9e7d"; }
      { type = "cursor"; keyColor = "#ff9e7d"; }
      { type = "custom"; format = "{#215}────────────────────────────────{#}"; }
      { type = "cpu"; keyColor = "#ffc98b"; }
      { type = "gpu"; keyColor = "#ffc98b"; }
      { type = "memory"; keyColor = "#ffc98b"; }
      { type = "disk"; keyColor = "#ffc98b"; }
      { type = "uptime"; keyColor = "#ffc98b"; }
      "break"
      { type = "colors"; symbol = "circle"; }
    ];
  };

  home.packages = with pkgs; [
    librewolf google-chrome
    kitty git wget eza zoxide fastfetch pciutils
    nemo ffmpegthumbnailer
    zed-editor nodejs_22 gpu-screen-recorder mpv libreoffice
    heroic prismlauncher modrinth-app mangohud vinegar
    vesktop qpwgraph xwayland-satellite gimp
    nerd-fonts.jetbrains-mono adw-gtk3 papirus-icon-theme
  ];

  programs.home-manager.enable = true;
}
