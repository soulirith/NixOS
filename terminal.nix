{ pkgs, ... }:

{
  # Shell Configuration (Fish)
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      set fish_greeting
    '';

    shellAliases = {
      ls = "eza --icons=always --group-directories-first";
      ll = "eza -la --icons=always --group-directories-first";
      gens = "doas nix-env --list-generations --profile /nix/var/nix/profiles/system";
      rollback = "doas nixos-rebuild switch --flake /etc/nixos#nixos --rollback";
      clean = "cd /etc/nixos; and doas nix-env --delete-generations +2 --profile /nix/var/nix/profiles/system; and doas nix-store --gc";
      quiet = "mode-quiet";
      perf = "mode-perf";
    };

    functions = {
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

  # Terminal Configuration (Foot - matched to your Kitty config)
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
        beam-thickness = "1.5px";
        blink = "yes";
        blink-rate = 500;
      };
      colors = {
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

