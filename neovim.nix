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
      which-key-nvim
      nvim-autopairs
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

      -- Function to apply Noctalia Matugen colors + clean glass transparency
      local function apply_theme()
        local ok, matugen = pcall(require, 'matugen')
        if ok then
          matugen.setup()
        end

        -- Make main editor background transparent so Foot's 0.35 glass shows through
        local transparent_groups = {
          "Normal", "NormalNC", "SignColumn", "LineNr", "EndOfBuffer",
          "NeoTreeNormal", "NeoTreeNormalNC", "NeoTreeEndOfBuffer"
        }
        for _, group in ipairs(transparent_groups) do
          vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
        end
      end

      apply_theme()

      -- Re-apply transparency automatically if Noctalia reloads matugen on SIGUSR1
      vim.api.nvim_create_autocmd("Signal", {
        pattern = "SIGUSR1",
        callback = function()
          vim.defer_fn(apply_theme, 50)
        end,
      })

      -- Enable Treesitter highlighting automatically
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })

      -- Auto-close brackets and quotes
      require('nvim-autopairs').setup({})

      -- Sleek rounded statusline synced to Noctalia
      require('lualine').setup({
        options = {
          theme = 'base16',
          component_separators = '|',
          section_separators = { left = '', right = '' },
        },
      })

      -- Visual file sidebar (Space + e)
      require('neo-tree').setup({
        close_if_last_window = true,
        window = { width = 28 },
      })

      -- Shortcut cheat-sheet popup when you press Space
      local wk = require('which-key')
      wk.setup({ delay = 300 })

      -- Normal, intuitive shortcuts (Zero Nano pain points)
      local map = vim.keymap.set
      map({ "n", "i", "v" }, "<C-s>", "<Esc>:w<CR>", { desc = "Save file" })
      map({ "n", "i", "v" }, "<C-q>", "<Esc>:q<CR>", { desc = "Quit" })
      map({ "n", "i" }, "<C-z>", "<Esc>ui", { desc = "Undo" })
      map("n", "<C-a>", "ggVG", { desc = "Select all" })
      map("v", "<C-c>", '"+y', { desc = "Copy selection" })
      map("n", "<Esc>", ":nohlsearch<CR>", { silent = true, desc = "Clear search highlight" })

      -- Leader shortcuts (Press Space to see this menu!)
      local builtin = require('telescope.builtin')
      map("n", "<leader>e", ":Neotree toggle<CR>", { silent = true, desc = "Toggle file tree" })
      map("n", "<leader>f", builtin.find_files, { desc = "Find files" })
      map("n", "<leader>g", builtin.live_grep, { desc = "Search text in files" })
      map("n", "<leader>w", ":w<CR>", { desc = "Save file" })
      map("n", "<leader>q", ":q<CR>", { desc = "Quit" })
    '';
  };
}

