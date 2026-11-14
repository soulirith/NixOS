{ pkgs, ... }:

{
  home.packages = with pkgs; [
    opencode
  ];

  # Declarative OpenCode Configuration
  xdg.configFile."opencode/opencode.json" = {
    force = true;
    text = builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";
      theme = "transparent-mocha";
      model = "ollama/qwen3-coder:30b";
      small_model = "ollama/qwen3-coder:30b";
      provider = {
        ollama = {
          npm = "@ai-sdk/openai-compatible";
          name = "Ollama";
          options = {
            baseURL = "http://127.0.0.1:11434/v1";
            apiKey = "ollama";
          };
          models = {
            "qwen3-coder:30b" = {
              name = "qwen3-coder:30b";
              tools = true;
              limit = {
                context = 32768;
                output = 8192;
              };
            };
          };
        };
      };
      permission = {
        edit = "allow";
        bash = {
          "git *" = "allow";
          "nix flake check*" = "allow";
          "doas nixos-rebuild test*" = "allow";
          "*" = "ask";
        };
      };
    };
  };

  # Declarative Transparent Catppuccin Mocha Theme
  xdg.configFile."opencode/themes/transparent-mocha.json" = {
    force = true;
    text = builtins.toJSON {
      "$schema" = "https://opencode.ai/theme.json";
      theme = {
        primary = "#89b4fa";
        secondary = "#cba6f7";
        accent = "#f5c2e7";
        error = "#f38ba8";
        warning = "#f9e2af";
        success = "#a6e3a1";
        info = "#94e2d5";
        text = "#cdd6f4";
        textMuted = "#a6adc8";
        background = "transparent"; # Changed from "none" to "transparent"
        backgroundPanel = "#181825";
        backgroundElement = "#313244";
        border = "#45475a";
        borderActive = "#89b4fa";
        borderSubtle = "#313244";
      };
    };
  };

  # Fish Aliases
  programs.fish.shellAliases = {
    agent = "ollama launch opencode --model qwen3-coder:30b";
    agent-stop = "ollama stop qwen3-coder:30b";
  };
}
