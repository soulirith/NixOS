{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      base16-nvim
      lualine-nvim
      nvim-web-devicons
      telescope-nvim
      plenary-nvim
      neo-tree-nvim
      nui-nvim
      nvim-autopairs
      gitsigns-nvim
      indent-blankline-nvim
      (nvim-treesitter.withPlugins (p: [
        p.nix
        p.lua
        p.fish
        p.bash
        p.rust
        p.kdl
        p.json
        p.toml
        p.markdown
      ]))
    ];

    extraConfig = ''
      set clipboard+=unnamedplus
      set termguicolors
      set mouse=a
      set number
      set cursorline
      set signcolumn=yes
      set expandtab
      set shiftwidth=2
      set tabstop=2
      set ignorecase
      set smartcase
      set undofile
      set scrolloff=8
    '';

    extraLuaConfig = ''
      -- Allow root (doas nvim) to load your Noctalia theme
      package.path = package.path .. ";/home/soulirith/.config/nvim/lua/?.lua"

      vim.g.mapleader = " "

      -- Apply Noctalia Matugen colors + full glass transparency + dynamic system highlight
      local function apply_theme()
        local ok, matugen = pcall(require, 'matugen')
        if ok then
          matugen.setup()
        end

        local transparent_groups = {
          "Normal", "NormalNC", "SignColumn", "LineNr", "EndOfBuffer",
          "CursorLine", "CursorLineNr", "StatusLine", "StatusLineNC",
          "WinSeparator", "VertSplit", "Folded", "FoldColumn",
          "NeoTreeNormal", "NeoTreeNormalNC", "NeoTreeEndOfBuffer",
          "NeoTreeStatusLine", "NeoTreeStatusLineNC", "NeoTreeWinSeparator"
        }
        for _, group in ipairs(transparent_groups) do
          vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
        end

        -- Pull Noctalia's dynamic system accent color for Visual selection & search
        local accent_hl = vim.api.nvim_get_hl(0, { name = "TelescopePromptTitle" })
        if accent_hl and accent_hl.bg then
          vim.api.nvim_set_hl(0, "Visual", {
            bg = accent_hl.bg,
            fg = accent_hl.fg or "#191e24",
            bold = true,
          })
          vim.api.nvim_set_hl(0, "Search", {
            bg = accent_hl.bg,
            fg = accent_hl.fg or "#191e24",
          })
          vim.api.nvim_set_hl(0, "IncSearch", {
            bg = accent_hl.bg,
            fg = accent_hl.fg or "#191e24",
          })
        end
      end

      apply_theme()

      -- Re-apply transparency & accent highlight when Noctalia updates matugen on SIGUSR1
      vim.api.nvim_create_autocmd("Signal", {
        pattern = "SIGUSR1",
        callback = function()
          vim.defer_fn(apply_theme, 50)
        end,
      })

      -- Enable Treesitter syntax highlighting
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })

      -- Subtle indent guides & Git gutter signs
      require('ibl').setup({
        indent = { char = "│" },
        scope = { enabled = false },
      })
      require('gitsigns').setup()
      require('nvim-autopairs').setup({})

      -- Sleek rounded statusline synced to Noctalia
      require('lualine').setup({
        options = {
          theme = 'base16',
          component_separators = '|',
          section_separators = { left = '', right = '' },
        },
      })

      -- Visual file sidebar (<Space>e)
      require('neo-tree').setup({
        close_if_last_window = true,
        window = { width = 28 },
      })

      local map = vim.keymap.set

      -- Keep clipboard intact when deleting or pasting over selections
      map({ "n", "v" }, "d", '"_d')
      map({ "n", "v" }, "D", '"_D')
      map({ "n", "v" }, "c", '"_c')
      map({ "n", "v" }, "C", '"_C')
      map({ "n", "v" }, "x", '"_x')
      map("v", "p", '"_dP')

      -- Quality-of-life shortcuts
      map({ "n", "i", "v" }, "<C-s>", "<Esc>:w<CR>")
      map("n", "<Esc>", ":nohlsearch<CR>", { silent = true })

      -- Leader shortcuts
      local builtin = require('telescope.builtin')
      map("n", "<leader>e", ":Neotree toggle<CR>", { silent = true })
      map("n", "<leader>f", builtin.find_files)
      map("n", "<leader>g", builtin.live_grep)
    '';
  };
}

