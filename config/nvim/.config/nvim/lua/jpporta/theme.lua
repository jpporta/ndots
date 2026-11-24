function source_current()
  -- Runtime theme fragment written by tooling/theme-switcher. Lives OUTSIDE this
  -- symlinked config dir (~/.config/nvim is a symlink into the repo) so the
  -- switcher and Home Manager never write the same path.
  -- dofile doesn't expand $HOME or ~
  local theme_path = os.getenv("HOME") .. "/.config/theme-switcher/nvim-current.lua"
  if vim.uv.fs_stat(theme_path) then
    dofile(theme_path)
  else
    -- No switcher on this host (yet): fall back to the bundled default.
    dofile(vim.fn.stdpath("config") .. "/lua/jpporta/themes/gruvbox-dark.lua")
  end
end

source_current()

-- Re-enable live reload: theme-switcher sends SIGUSR1 to nvim processes on switch.
vim.api.nvim_create_autocmd("Signal", {
  pattern = "SIGUSR1",
  callback = function()
    source_current()
  end,
})
