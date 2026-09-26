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
  };

  #Inline Neovim config
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

    -- Settings
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

    local function apply_custom_highlights()
      -- Try loading Noctalia's native matugen file
      local has_matugen, matugen = pcall(require, 'matugen')
      local has_base16, base16 = pcall(require, 'base16-colorscheme')
      
      local c = (has_base16 and base16.colorscheme) or {}

      -- Use active accent hue dynamically for comments, fallback to soft gray
      local theme_comment = (has_matugen and matugen.colors and matugen.colors.primary) or c.base0A or "#949494"

      local comment_opts = { 
        fg = theme_comment, 
        bg = "NONE",
        italic = true, 
        bold = true,
        default = false
      }

      local comment_groups = {
        "Comment",
        "@comment",
        "@comment.documentation",
        "@comment.line",
        "@comment.block",
        "NixComment",
      }

      for _, group in ipairs(comment_groups) do
        vim.api.nvim_set_hl(0, group, comment_opts)
      end

      if c.base05 then
        vim.api.nvim_set_hl(0, "Normal", { fg = c.base05, bg = "NONE" })
        vim.api.nvim_set_hl(0, "@punctuation.special", { fg = c.base0D, bold = true })
        vim.api.nvim_set_hl(0, "@punctuation.bracket", { fg = c.base0D })
        vim.api.nvim_set_hl(0, "@punctuation.delimiter", { fg = c.base05 })
        vim.api.nvim_set_hl(0, "@string", { fg = c.base0B })
        vim.api.nvim_set_hl(0, "@keyword", { fg = c.base0E, bold = true })
        vim.api.nvim_set_hl(0, "@function", { fg = c.base0D })
        vim.api.nvim_set_hl(0, "@variable", { fg = c.base05 })
        vim.api.nvim_set_hl(0, "@type", { fg = c.base0A })
        vim.api.nvim_set_hl(0, "@constant", { fg = c.base09 })
        vim.api.nvim_set_hl(0, "@number", { fg = c.base09 })
        vim.api.nvim_set_hl(0, "@boolean", { fg = c.base09 })
        vim.api.nvim_set_hl(0, "@operator", { fg = c.base05 })
        vim.api.nvim_set_hl(0, "@property", { fg = c.base05 })
        vim.api.nvim_set_hl(0, "LineNr", { fg = c.base04, bold = true })
        vim.api.nvim_set_hl(0, "CursorLineNr", { fg = c.base0A, bold = true })
      end
    end

    apply_custom_highlights()

    vim.api.nvim_create_autocmd({"ColorScheme", "BufEnter", "FocusGained"}, {
      callback = apply_custom_highlights,
    })
  '';
 
 
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
        hash = "sha256-K0EUIsYXrt0Nr8rPuj+V4IF6vyDJ3ZX+WUulo9nP+Lk=";
      };
      injectCss = true;
      replaceColors = true;
      overwriteAssets = true;
      injectThemeJs = true;
    };
  };

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
        padding = {
          top = 1;
        };
      };
      display = {
        separator = "  ";
        key = {
          type = "icon";
        };
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
    kitty git wget eza zoxide pciutils
    nemo ffmpegthumbnailer unimatrix btop pipes
    zed-editor nodejs_22 gpu-screen-recorder
    heroic prismlauncher mangohud vinegar smartmontools easyeffects
    vesktop xwayland-satellite starship mpvpaper keepassxc bottles yt-dlp
    nerd-fonts.jetbrains-mono adw-gtk3 papirus-icon-theme motrix-next file-roller nemo-fileroller
  ];

  programs.home-manager.enable = true;
}
