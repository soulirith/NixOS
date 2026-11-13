{ pkgs, ... }:

{
  # Declarative Macchina Configuration (Full Eye-Candy Dashboard)
  xdg.configFile."macchina/macchina.toml".text = ''
    theme = "Catppuccin"

    show = [
      "Distribution",
      "Host",
      "WindowManager",
      "Kernel",
      "Packages",
      "Shell",
      "Terminal",
      "Resolution",
      "Processor",
      "GPU",
      "Memory",
      "DiskSpace",
      "LocalIP",
      "Battery",
      "Uptime"
    ]

    long_uptime = false
    long_shell = false
    long_kernel = false
    current_shell = true
    physical_cores = true
  '';

  # Declarative Catppuccin Mocha Eye-Candy Theme
  xdg.configFile."macchina/themes/Catppuccin.toml".text = ''
    spacing = 2
    padding = 1
    hide_ascii = false
    prefer_small_ascii = false
    key_color = "#cba6f7"
    separator = "│"
    separator_color = "#585b70"

    [palette]
    type = "Dark"
    visible = true
    glyph = "● "

    [bar]
    glyph = "━"
    symbol_open = "["
    symbol_close = "]"
    visible = true
    hide_delimiters = true

    [box]
    title = "    soulirith@nixos "
    border = "rounded"
    visible = true

    [box.inner_margin]
    x = 2
    y = 1

    [randomize]
    key_color = false
    separator_color = false

    [keys]
    distro = "   OS      "
    host = "   Host    "
    window_manager = "   WM      "
    kernel = "   Kernel  "
    packages = "   Pkgs    "
    shell = " Shell   "
    terminal = " Term    "
    resolution = "   Display "
    processor = "   CPU     "
    gpu = "   GPU     "
    memory = "   RAM     "
    disk_space = "   Disk    "
    local_ip = "   IP      "
    battery = "   Battery "
    uptime = "   Uptime  "
  '';

  # Shell Configuration (Fish)
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      set fish_greeting
      if string match -q "foot*" "$TERM"
        macchina
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

  # Terminal Configuration (Foot - matched to your Kitty config & Foot 1.26+)
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

