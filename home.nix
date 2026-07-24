{ config, pkgs, inputs, ... }:
{
  home.username = "soulirith";
  home.homeDirectory = "/home/soulirith";
  home.stateVersion = "26.05";

  imports = [
    inputs.noctalia.homeModules.default
    inputs.spicetify-nix.homeManagerModules.default
  ];

  programs.noctalia.enable = true;

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = "nemo.desktop";
    };
  };

  # Fastfetch cursor / libdecor theme source
  xdg.configFile."gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name=adw-gtk3-dark
    gtk-icon-theme-name=Papirus-Dark
    gtk-cursor-theme-name=catppuccin-mocha-dark-cursors
    gtk-cursor-theme-size=24
    gtk-application-prefer-dark-theme=1
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

  # Wayland titlebar
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

  # Shift_R+F12
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

  # Named ANSI colors, tracks kitty theme via template
  xdg.configFile."fastfetch/config.jsonc".text = builtins.toJSON {
    logo.padding.top = 1;
    display.key.type = "both";
    modules = [
      { type = "title"; color = { user = "yellow"; at = "white"; host = "red"; }; }
      { type = "custom"; format = "{#red}────────────────────────────────{#}"; }
      { type = "os"; keyColor = "red"; }
      { type = "kernel"; keyColor = "red"; }
      { type = "packages"; keyColor = "red"; }
      { type = "display"; keyColor = "red"; }
      { type = "wm"; keyColor = "red"; }
      { type = "terminal"; keyColor = "red"; }
      { type = "terminalfont"; keyColor = "red"; }
      { type = "cursor"; keyColor = "red"; }
      { type = "custom"; format = "{#yellow}────────────────────────────────{#}"; }
      { type = "cpu"; keyColor = "yellow"; }
      { type = "gpu"; keyColor = "yellow"; }
      { type = "memory"; keyColor = "yellow"; }
      { type = "disk"; keyColor = "yellow"; }
      { type = "uptime"; keyColor = "yellow"; }
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
