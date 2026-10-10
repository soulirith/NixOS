{ config, pkgs, inputs, lib, ... }:
{
  home.username = "soulirith";
  home.homeDirectory = "/home/soulirith";
  home.stateVersion = "26.05";

  imports = [
    # inputs.stylix.homeManagerModules.stylix
  ];

  stylix = {
    enable = true;
    image = ./Pictures/Wallpaper/wallhaven-yqk2q7.jpg;
    polarity = "dark";
    
    cursor = {
      name = "catppuccin-mocha-dark-cursors";
      package = pkgs.catppuccin-cursors.mochaDark;
      size = 24;
    };

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };
      sizes = {
        applications = 11;
        terminal = 12;
        desktop = 11;
        popups = 12;
      };
    };
    
    targets.btop.enable = false;
    targets.cava.enable = false;
    targets.gtk.enable = false;
    targets.kitty.enable = false;
    targets.qt.enable = false;
    targets.starship.enable = false;
    targets.neovim.enable = true;
  };

  # Environment Variables
  home.sessionVariables = {
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
        default.path = lib.mkForce "/home/soulirith/Pictures/fuji-sunset.jpg";
      };

      templates = {
        neovim = {
          input_path = "~/.config/noctalia/templates/neovim.lua.template";
          output_path = "~/.config/nvim/lua/matugen.lua";
        };
      };
    };
  };

  # Custom noctalia template for nvim (bright comments + glass transparency)
 /*
 xdg.configFile."noctalia/templates/neovim.lua.template".text = ''
    local M = {}

    function M.setup()
      require('base16-colorscheme').setup({
        base00 = '{{colors.surface.default.hex}}',
        base01 = '{{colors.surface_container_low.default.hex}}',
        base02 = '{{colors.surface_container.default.hex}}',
        base03 = '{{colors.primary.default.hex}}',
        base04 = '{{colors.outline_variant.default.hex}}',
        base05 = '{{colors.on_surface.default.hex}}',
        base06 = '{{colors.on_surface.default.hex}}',
        base07 = '{{colors.on_surface.default.hex}}',
        base08 = '{{colors.error.default.hex}}',
        base09 = '{{colors.tertiary.default.hex}}',
        base0A = '{{colors.primary.default.hex}}',
        base0B = '{{colors.secondary.default.hex}}',
        base0C = '{{colors.secondary_container.default.hex}}',
        base0D = '{{colors.primary_container.default.hex}}',
        base0E = '{{colors.tertiary_container.default.hex}}',
        base0F = '{{colors.error_container.default.hex}}',
      })

      local transparent_groups = {
        "Normal", "NormalNC", "SignColumn", "NormalFloat", 
        "FloatBorder", "LineNr", "CursorLineNr", "EndOfBuffer",
        "TelescopeNormal", "TelescopeBorder", "TelescopePromptNormal",
        "TelescopePromptBorder", "MiniPickNormal", "MiniPickBorder"
      }
      for _, group in ipairs(transparent_groups) do
        vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
      end

      local comment_groups = { "Comment", "@comment", "@comment.documentation", "@comment.line", "@comment.block", "NixComment" }
      for _, group in ipairs(comment_groups) do
        vim.api.nvim_set_hl(0, group, { fg = '{{colors.primary.default.hex}}', bg = "NONE", italic = true, bold = true })
      end
    end

    if _G.__matugen_signal then
      _G.__matugen_signal:stop()
      _G.__matugen_signal:close()
    end

    local signal = vim.uv.new_signal()
    _G.__matugen_signal = signal
    signal:start(
      'sigusr1',
      vim.schedule_wrap(function()
        package.loaded['matugen'] = nil
        local has_m, m = pcall(require, 'matugen')
        if has_m and type(m) == 'table' and m.setup then
          m.setup()
        end
      end)
    )

    return M
    '';
*/
  # Browser MIME associations (Ensures Nemo is default directory handler)
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

  # Neovim configuration
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
      extraConfig = ''
      set clipboard+=unnamedplus
    '';
  };
/*
xdg.configFile."nvim/init.lua".text = ''
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
    vim.opt.laststatus = 0
    vim.opt.clipboard = "unnamedplus"

    require("lazy").setup({
      { "RRethy/base16-nvim" },
    })

    local has_matugen, matugen = pcall(require, "matugen")
    if has_matugen and matugen.setup then
      matugen.setup()
    end
  '';
  */
  # GTK configurations
  xdg.configFile."gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-icon-theme-name=Papirus-Dark
    gtk-application-prefer-dark-theme=1
  '';

  # Zsh Configuration Block
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
    alias reb="(cd /etc/nixos && git add -A && doas nixos-rebuild switch --flake . && (git diff --cached --quiet || git commit -m \"rebuild: \$(date +%Y-%m-%d\ %H:%M)\") && git push)"
    alias upd="(cd /etc/nixos && nix flake update && git add -A && doas nixos-rebuild switch --flake . && (git diff --cached --quiet || git commit -m \"flake update: \$(date +%Y-%m-%d\ %H:%M)\") && git push)"
    eval "$(starship init zsh)"
  '';
};
  # CLI Utilities Integration
  programs.fzf = { enable = true; enableZshIntegration = true; };
  programs.zoxide = { enable = true; enableZshIntegration = true; };

  # MPV
  programs.mpv = {
    enable = true;
    config = {
      hwdec = "auto-safe";
      vo = "gpu-next";
      video-sync = "display-resample";
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
  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        source = "NixOS_small";
        padding = { top = 1; };
      };
      display = {
        separator = "  ";
        key = { type = "icon"; };
      };
      modules = [
        { type = "os"; }
        { type = "kernel"; }
        { type = "wm"; }
        { type = "shell"; }
        { type = "terminal"; }
        { type = "cpu"; }
        { type = "gpu"; }
        { type = "memory"; }
        { type = "disk"; }
        { type = "packages"; }
        { type = "battery"; }
        { type = "uptime"; }
      ];
    };
  };

  # Home packages
  home.packages = with pkgs; [
    librewolf google-chrome wl-clipboard
    kitty git wget eza pciutils
    nemo ffmpegthumbnailer unimatrix btop pipes
    zed-editor nodejs_22 gpu-screen-recorder
    heroic prismlauncher mangohud vinegar smartmontools easyeffects
    vesktop xwayland-satellite starship mpvpaper keepassxc yt-dlp
    adw-gtk3 papirus-icon-theme motrix-next file-roller nemo-fileroller
    xdg-desktop-portal-xapp sonixd 
  ];

  programs.home-manager.enable = true;
}
