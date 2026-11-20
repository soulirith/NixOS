{ pkgs, ... }:

{
  # Install Rustfetch & Foot
  home.packages = with pkgs; [
    rustfetch
    foot
  ];

  # Declarative Rustfetch Configuration
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
        rustfetch | awk '
          { lines[NR] = $0 }
          END {
            for (i = 1; i <= 7; i++) {
              match(lines[i], /(soulirith@|---|OS:|Kernel:|CPU:|Screen:|RAM:)/)
              logo[i] = substr(lines[i], 1, RSTART - 1)
              sub(/ +$/, "", logo[i])
              info[i] = substr(lines[i], RSTART)
            }
            for (i = 8; i <= NR; i++) {
              sub(/^ +/, "", lines[i])
              info[i] = lines[i]
            }

            for (i = 1; i <= NR; i++) {
              sub(/^OS:/,          "  OS      ", info[i])
              sub(/^Kernel:/,      "  Kernel  ", info[i])
              sub(/^CPU:/,         "  CPU     ", info[i])
              sub(/^Screen:/,      "  Screen  ", info[i])
              sub(/^RAM:/,         "\356\277\205  RAM     ", info[i])
              sub(/^Uptime:/,      "  Uptime  ", info[i])
              sub(/^Battery:/,     "  Power   ", info[i])
              sub(/^Disk \(\/\):/, "  Disk    ", info[i])

              l = (i >= 3 && i <= 9) ? logo[i - 2] : ""
              printf "%s\033[23G%s\n", l, info[i]
            }
          }
        '
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
  systemd.user.services.foot-server = {
    Unit = {
      Description = "Foot terminal server";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.foot}/bin/foot --server";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  xdg.configFile."foot/foot.ini" = {
    force = true;
    text = ''
      [main]
      shell=${pkgs.fish}/bin/fish
      font=JetBrainsMono Nerd Font:size=12
      pad=12x12

      [cursor]
      style=beam
      beam-thickness=1.5
      blink=yes
      blink-rate=500

      [colors-dark]
      alpha=0.40
    '';
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

