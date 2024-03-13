-- source vimrc
vim.cmd('source ~/.vim/vimrc')

-- disable augroup from /etc/vim/sysinit.vim, since it causes weird issues
vim.cmd('autocmd! gentoo')

vim.opt.laststatus = 0
vim.opt.number = false
vim.opt.confirm = false
-- vim.opt.showcmd = false
-- vim.opt.cmdheight = 1
vim.opt.autoread = false
vim.opt.confirm = false
vim.opt.exrc = false
vim.opt.backup = false
vim.opt.undofile = false

vim.api.nvim_create_autocmd("UIEnter", {
  callback = function()
    vim.fn.timer_start(50, function()
      vim.opt.lines = 5
    end)
  end,
})

vim.api.nvim_set_keymap("n", "", "ZZ", { noremap = true })
-- vim.api.nvim_set_keymap("i", "<CR>", "ZZ", { noremap = true })

-- plugins
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")
