-- options
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.termguicolors = true
-- unfold all by default but keep treesitter folding
vim.opt.foldlevelstart = 99

vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)

vim.g.markdown_fenced_languages = {
	"ts=typescript",
}

-- keymaps
vim.keymap.set("i", "<C-c>", "<Esc>")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("n", "<leader>wh", ":split<CR>", { silent = true })
vim.keymap.set("n", "<leader>wv", ":vsplit<CR>", { silent = true })
vim.keymap.set("n", "<leader>wd", ":close<CR>", { silent = true })
