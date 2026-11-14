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

  # Fish Aliases
  programs.fish.shellAliases = {
    agent = "ollama launch opencode --model qwen3-coder:30b";
    agent-stop = "ollama stop qwen3-coder:30b";
  };
}
