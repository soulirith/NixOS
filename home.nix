{ config, pkgs, inputs, ... }:
{
  home.username = "soulirith";
  home.homeDirectory = "/home/soulirith";
  home.stateVersion = "26.05";

  imports = [
    inputs.noctalia.homeModules.default
    inputs.spicetify-nix.homeManagerModules.default
  ];
  
  # Environment Variables
  home.sessionVariables = {
    # Helps Nemo handle Wayland structures and layouts correctly outside of Cinnamon
    XDG_CURRENT_DESKTOP = "X-Cinnamon";
  };

  # Noctalia
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

  # Browser MIME association
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = "nemo.desktop";
      "x-scheme-handler/http" = "google-chrome.desktop";
      "x-scheme-handler/https" = "google-chrome.desktop";
      "x-scheme-handler/about" = "google-chrome.desktop";
      "x-scheme-handler/unknown" = "google-chrome.desktop";
      "text/html" = "google-chrome.desktop";
    };
  };

 
  # Neovim replaces nano
programs.neovim = {
  enable = true;
  defaultEditor = true;
  viAlias = true;
  vimAlias = true;
  extraLuaConfig = ''
    -- Bootstrap lazy.nvim
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not vim.loop.fs_stat(lazypath) then
      vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", lazypath,
      })
    end
    vim.opt.rtp:prepend(lazypath)

    vim.opt.number = true
    vim.opt.relativenumber = false
    vim.opt.expandtab = true
    vim.opt.shiftwidth = 2
    vim.opt.tabstop = 2
    vim.opt.laststatus = 3

    require("lazy").setup({
  { "RRethy/base16-nvim" },
})

local function apply_custom_highlights()
local signal = vim.uv.new_signal()
signal:start('sigusr1', vim.schedule_wrap(function()
  apply_custom_highlights()
end))
'';
};

  # GTK 3.0
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
  
  # Zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    autosuggestion.highlight = "fg=#8899aa";
    shellAliases = {
      ls = "eza --icons=always --group-directories-first";
      ll = "eza -la --icons=always --group-directories-first";
      gens = "doas nix-env --list-generations --profile /nix/var/nix/profiles/system";
      rollback = "doas nixos-rebuild switch --flake /etc/nixos#nixos --rollback";
      clean = "(cd /etc/nixos && doas nix-env --delete-generations +2 --profile /nix/var/nix/profiles/system && doas nix-store --gc)";
    };

    initContent = ''
      fastfetch
      alias reb='(cd /etc/nixos && git add -A && doas nixos-rebuild switch --flake . && (git diff --cached --quiet || git commit -m "rebuild: $(date +%Y-%m-%d\ %H:%M)") && git push)'
      alias upd='(cd /etc/nixos && nix flake update && git add -A && doas nixos-rebuild switch --flake . && (git diff --cached --quiet || git commit -m "flake update: $(date +%Y-%m-%d\ %H:%M)") && git push)'
      eval "$(starship init zsh)"
    '';
  };

  programs.fzf = { enable = true; enableZshIntegration = true; };
  programs.zoxide = { enable = true; enableZshIntegration = true; };

  # Spicetify
  programs.spicetify = let
    spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  in {
    enable = true;
    enabledExtensions = with spicePkgs.extensions; [
      adblock
      hidePodcasts
    ];
    theme = {
      name = "Hazy";
      src = pkgs.fetchFromGitHub {
        owner = "Astromations";
        repo = "Hazy";
        rev = "main";
        hash = "sha256-2D8hcPaAqsXv7krzd8n77LqxaQzf2GMCqiDuq1YHLks=";
      };
      injectCss = true;
      replaceColors = true;
      overwriteAssets = true;
      injectThemeJs = true;
    };
  };
  
  # MangoHUD
  xdg.configFile."MangoHud/MangoHud.conf".text = ''
    legacy_layout=0
    no_display=0

    position=top-left
    font_size=14

    fps
    fps_color_change
    frame_timing

    gpu_color=ff9e7d
    background_alpha=0
    text_outline

    toggle_hud=Shift_R+F12
  '';

  # Fastfetch
  xdg.configFile."fastfetch/config.jsonc".text = builtins.toJSON {
    logo = {
      padding.top = 1;
      height = 12;
    };
    display.key.type = "both";
    modules = [
      { type = "title"; color = { user = "magenta"; at = "white"; host = "blue"; }; }
      { type = "custom"; format = "{#magenta}────────────────────────────────{#}"; }
      { type = "os"; keyColor = "magenta"; }
      { type = "kernel"; keyColor = "magenta"; }
      { type = "packages"; keyColor = "magenta"; }
      { type = "display"; keyColor = "magenta"; }
      { type = "wm"; keyColor = "magenta"; }
      { type = "terminal"; keyColor = "magenta"; }
      { type = "terminalfont"; keyColor = "magenta"; }
      { type = "cursor"; keyColor = "magenta"; }
      { type = "custom"; format = "{#blue}────────────────────────────────{#}"; }
      { type = "cpu"; keyColor = "blue"; }
      { type = "gpu"; keyColor = "blue"; }
      { type = "memory"; keyColor = "blue"; }
      { type = "disk"; keyColor = "blue"; }
      { type = "uptime"; keyColor = "blue"; }
      "break"
      { type = "colors"; symbol = "circle"; }
    ];
  };  

  # Home packages
  home.packages = with pkgs; [
    librewolf google-chrome
    kitty git wget eza zoxide fastfetch pciutils
    nemo ffmpegthumbnailer unimatrix btop pipes
    zed-editor nodejs_22 gpu-screen-recorder mpv
    heroic prismlauncher mangohud vinegar smartmontools easyeffects
    vesktop xwayland-satellite starship mpvpaper keepassxc bottles
    nerd-fonts.jetbrains-mono adw-gtk3 papirus-icon-theme motrix-next file-roller nemo-fileroller
  ];
  programs.home-manager.enable = true;
}

