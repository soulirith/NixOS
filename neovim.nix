{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      base16-nvim
    ];

    extraConfig = ''
      set clipboard+=unnamedplus
      set termguicolors
    '';

    initLua = ''
      local ok, matugen = pcall(require, 'matugen')
      if ok then
        matugen.setup()
      end

      -- Live-reload colors when Noctalia updates matugen.lua
      vim.api.nvim_create_autocmd("Signal", {
        pattern = "SIGUSR1",
        callback = function()
          package.loaded["matugen"] = nil
          local reloaded, mod = pcall(require, "matugen")
          if reloaded then
            mod.setup()
          end
        end,
      })
    '';
  };
}

