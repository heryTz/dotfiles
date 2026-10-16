vim.pack.add({
	"https://github.com/folke/trouble.nvim",
})

local trouble = require("trouble")
trouble.setup()

vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { silent = true })
vim.keymap.set("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { silent = true })
vim.keymap.set("n", "]x", function()
	trouble.next({ skip_groups = true, jump = true })
end)
vim.keymap.set("n", "[x", function()
	trouble.prev({ skip_groups = true, jump = true })
end)
