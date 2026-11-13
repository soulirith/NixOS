{ pkgs, ... }:

{
  # Install Rustfetch
  home.packages = with pkgs; [
    rustfetch
  ];

  # Declarative Rustfetch Configuration (force = true overwrites any existing file automatically)
  xdg.configFile."rustfetch/config.toml" = {
    force = true;
    text = ''
      [display]
      identifier = true
      os = true
      kernel = true
      uptime = true

      cpu = true
          cpu_frequency = false

      gpu = false
      screen = true
          resolution = true
          refresh_rate = true

      ram = true
      swap = false

      disk = true

      battery = true
      power_draw = false
    '';
  };

  # Shell Configuration (Fish)
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      set fish_greeting
      if string match -q "foot*" "$TERM"
        rustfetch | expand -t 2
      end
    '';

    shellAliases = {
      ls = "eza --icons=always --group-directories-first";
      ll = "eza -la --icons=always --group-directories-first";
      gens = "doas nix-env --list-generations --profile /nix/var/nix/profiles/system";
      rollback = "doas nixos-rebuild switch --flake /etc/nixos#nixos --rollback";
      clean = "cd /etc/nixos; and doas nix-env --delete-generations +2 --profile /nix/var/nix/profiles/system; and doas nix-store --gc";
      quiet = "mode-quiet";
      perf = "mode-perf";

      # Quick pinned config jumps
      nconf = "doas -E nvim /etc/nixos/configuration.nix";
      nhome = "doas -E nvim /etc/nixos/home.nix";
      nterm = "doas -E nvim /etc/nixos/terminal.nix";
      nnvim = "doas -E nvim /etc/nixos/neovim.nix";
      nflake = "doas -E nvim /etc/nixos/flake.nix";
    };

    functions = {
      nixcfg = ''
        set -l files \
          "/etc/nixos/configuration.nix" \
          "/etc/nixos/home.nix" \
          "/etc/nixos/terminal.nix" \
          "/etc/nixos/neovim.nix" \
          "/etc/nixos/flake.nix"

        set -l choice (printf "%s\n" $files | fzf --height=30% --reverse --border --prompt="Nix Config > ")
        if test -n "$choice"
          doas -E nvim "$choice"
        end
      '';

      reb = ''
        cd /etc/nixos
        and git add -A
        and doas nixos-rebuild switch --flake .#nixos
        and begin
          git diff --cached --quiet; or git commit -m "rebuild: "(date +"%Y-%m-%d %H:%M")
        end
        and git push
      '';

      upd = ''
        cd /etc/nixos
        and nix flake update
        and git add -A
        and doas nixos-rebuild switch --flake .#nixos
        and begin
          git diff --cached --quiet; or git commit -m "flake update: "(date +"%Y-%m-%d %H:%M")
        end
        and git push
      '';
    };
  };

  # Terminal Configuration (Foot)
  programs.foot = {
    enable = true;
    server.enable = true;
    settings = {
      main = {
        shell = "${pkgs.fish}/bin/fish";
        font = "JetBrainsMono Nerd Font:size=12";
        pad = "12x12";
      };
      cursor = {
        style = "beam";
        beam-thickness = "1.5";
        blink = "yes";
        blink-rate = 500;
      };
      colors-dark = {
        alpha = "0.35";
        background = "1e1e2e";
        foreground = "cdd6f4";
        regular0 = "45475a";
        regular1 = "f38ba8";
        regular2 = "a6e3a1";
        regular3 = "f9e2af";
        regular4 = "89b4fa";
        regular5 = "f5c2e7";
        regular6 = "94e2d5";
        regular7 = "bac2de";
        bright0 = "585b70";
        bright1 = "f38ba8";
        bright2 = "a6e3a1";
        bright3 = "f9e2af";
        bright4 = "89b4fa";
        bright5 = "f5c2e7";
        bright6 = "94e2d5";
        bright7 = "a6adc8";
      };
    };
  };

  # Prompt & CLI Helpers
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };
}

