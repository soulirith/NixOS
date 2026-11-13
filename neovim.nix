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

      local function apply_theme()
        local ok, matugen = pcall(require, 'matugen')
        if ok then
          matugen.setup()
        end

        -- Clear all solid backgrounds so Foot's glass transparency is spotless
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

        -- Pull Noctalia's live accent & surface colors from Matugen
        local primary_hl = vim.api.nvim_get_hl(0, { name = "TelescopePromptTitle" })
        local secondary_hl = vim.api.nvim_get_hl(0, { name = "TelescopePreviewTitle" })
        local fg_hl = vim.api.nvim_get_hl(0, { name = "Normal" })

        local accent = primary_hl.bg and string.format("#%06x", primary_hl.bg) or "#679ee4"
        local accent2 = secondary_hl.bg and string.format("#%06x", secondary_hl.bg) or "#655cd6"
        local dark_fg = primary_hl.fg and string.format("#%06x", primary_hl.fg) or "#191e24"
        local text_fg = fg_hl.fg and string.format("#%06x", fg_hl.fg) or "#f2f2f3"

        -- Apply Noctalia accent to Visual selection & Search
        vim.api.nvim_set_hl(0, "Visual", { bg = accent, fg = dark_fg, bold = true })
        vim.api.nvim_set_hl(0, "Search", { bg = accent, fg = dark_fg })
        vim.api.nvim_set_hl(0, "IncSearch", { bg = accent2, fg = dark_fg })

        -- Clean, transparent Lualine theme (no muddy tint, no extra icons)
        local noctalia_lualine = {
          normal = {
            a = { bg = accent, fg = dark_fg, gui = "bold" },
            b = { bg = "NONE", fg = accent },
            c = { bg = "NONE", fg = text_fg },
          },
          insert = {
            a = { bg = accent2, fg = dark_fg, gui = "bold" },
            b = { bg = "NONE", fg = accent2 },
            c = { bg = "NONE", fg = text_fg },
          },
          visual = {
            a = { bg = accent2, fg = dark_fg, gui = "bold" },
            b = { bg = "NONE", fg = accent2 },
            c = { bg = "NONE", fg = text_fg },
          },
          command = {
            a = { bg = accent, fg = dark_fg, gui = "bold" },
            b = { bg = "NONE", fg = accent },
            c = { bg = "NONE", fg = text_fg },
          },
          inactive = {
            a = { bg = "NONE", fg = text_fg },
            b = { bg = "NONE", fg = text_fg },
            c = { bg = "NONE", fg = text_fg },
          },
        }

        require('lualine').setup({
          options = {
            theme = noctalia_lualine,
            component_separators = "",
            section_separators = { left = '', right = '' },
          },
          sections = {
            lualine_a = { 'mode' },
            lualine_b = { 'branch', 'diff' },
            lualine_c = { 'filename' },
            lualine_x = {},
            lualine_y = { 'progress' },
            lualine_z = { 'location' },
          },
        })
      end

      apply_theme()

      -- Re-apply theme & Lualine live whenever Noctalia changes wallpaper (SIGUSR1)
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

      -- Git gutter signs & auto-closing brackets
      require('gitsigns').setup()
      require('nvim-autopairs').setup({})

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

