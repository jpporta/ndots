return {
    'kdheepak/lazygit.nvim',
    config = function()

        vim.keymap.set('n', '<leader>gg', function() vim.cmd('LazyGit') end,
                       {desc = "LazyGit"})
    end,
    event = "VeryLazy"
}
