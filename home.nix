{ config, pkgs, inputs, ... }:
{
  home.username = "soulirith";
  home.homeDirectory = "/home/soulirith";
  home.stateVersion = "26.05";

  imports = [
    inputs.noctalia.homeModules.default
    inputs.spicetify-nix.homeManagerModules.default
  ];

  # Shell/panel + theming source of truth (GTK/Qt/Niri). Never add a `gtk` block here, it locks Noctalia out.
  programs.noctalia = {
    enable = true;
    settings = {
      theme = {
        mode = "dark";
        source = "community";
        community = "Kanagawa";
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

  # Cursor
  home.pointerCursor = {
    enable = true;
    name = "catppuccin-mocha-dark-cursors";
    package = pkgs.catppuccin-cursors.mochaDark;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  # Default file manager
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = "org.gnome.Nautilus.desktop";
    };
  };

  # Shell + aliases
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ls = "eza --icons=always --group-directories-first";
      ll = "eza -la --icons=always --group-directories-first";
      gens = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
      rollback = "sudo nixos-rebuild switch --flake /etc/nixos#nixos --rollback";
      clean = "(cd /etc/nixos && sudo nix-env --delete-generations +2 --profile /nix/var/nix/profiles/system && sudo nix-store --gc)";
    };
    # reb/upd live here, not in shellAliases, because of the nested quoting
    initContent = ''
      fastfetch
      alias reb='(cd /etc/nixos && git add . && git commit -m "rebuild: $(date +%Y-%m-%d\ %H:%M)" && git push && sudo nixos-rebuild switch --flake .)'
      alias upd='(cd /etc/nixos && nix flake update && git add . && git commit -m "flake update: $(date +%Y-%m-%d\ %H:%M)" && git push && sudo nixos-rebuild switch --flake .)'
    '';
  };

  # Prompt (colors come from the terminal, not set here)
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

  # Fuzzy find + smart cd + multiplexer
  programs.fzf = { enable = true; enableZshIntegration = true; };
  programs.zoxide = { enable = true; enableZshIntegration = true; };
  programs.zellij.enable = true;

  # Terminal. HM owns kitty.conf, so leave the Kitty template off in Noctalia.
  programs.kitty = {
    enable = true;
    settings = {
      confirm_os_window_close = 0;
      font_family = "JetBrainsMono Nerd Font";
      font_size = "10.0";
      background_opacity = "0.5";
      background_blur = "1";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      window_padding_width = 16;
    };
  };

  # Spotify + adblock
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

  # Game overlay, Shift_R+F12 to toggle. Hex is manual, no Noctalia template exists.
  xdg.configFile."MangoHud/MangoHud.conf".text = ''
    fps
    frame_timing
    cpu_stats
    gpu_stats

    round_corners=8
    background_alpha=0.3
    background_color=1f1f28
    text_color=dcd7ba
    gpu_color=957fb8
    cpu_color=7e9cd8
    font_size=16
    position=top-left
    toggle_hud=Shift_R+F12
    no_display=0
  '';

  # Fetch on shell start. Hex is manual, same reason as MangoHud.
  xdg.configFile."fastfetch/config.jsonc".text = builtins.toJSON {
    logo.padding.top = 1;
    display.key.type = "both";
    modules = [
      { type = "title"; color = { user = "#7e9cd8"; at = "#727169"; host = "#957fb8"; }; }
      { type = "custom"; format = "{#magenta}────────────────────────────────{#}"; }
      { type = "os"; keyColor = "#957fb8"; }
      { type = "kernel"; keyColor = "#957fb8"; }
      { type = "packages"; keyColor = "#957fb8"; }
      { type = "display"; keyColor = "#957fb8"; }
      { type = "wm"; keyColor = "#957fb8"; }
      { type = "terminal"; keyColor = "#957fb8"; }
      { type = "terminalfont"; keyColor = "#957fb8"; }
      { type = "cursor"; keyColor = "#957fb8"; }
      { type = "custom"; format = "{#blue}────────────────────────────────{#}"; }
      { type = "cpu"; keyColor = "#7e9cd8"; }
      { type = "gpu"; keyColor = "#7e9cd8"; }
      { type = "memory"; keyColor = "#7e9cd8"; }
      { type = "disk"; keyColor = "#7e9cd8"; }
      { type = "uptime"; keyColor = "#7e9cd8"; }
      "break"
      { type = "colors"; symbol = "circle"; }
    ];
  };

  home.packages = with pkgs; [
    brave google-chrome                                              # browsers
    kitty git wget eza zoxide fastfetch pciutils                     # cli
    nautilus ffmpegthumbnailer                                       # files + video thumbs
    vscodium nodejs_22                                               # dev
    heroic prismlauncher modrinth-app gamemode mangohud vinegar      # gaming
    vesktop qpwgraph xwayland-satellite                              # desktop
    nerd-fonts.jetbrains-mono                                        # fonts
  ];

  programs.home-manager.enable = true;
}
