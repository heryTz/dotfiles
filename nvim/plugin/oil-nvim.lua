vim.pack.add({
  "https://github.com/echasnovski/mini.icons",
  "https://github.com/stevearc/oil.nvim",
})

require("oil").setup({
  use_default_keymaps = false,
  columns = {
    "icon",
    "permissions",
    "size",
    "mtime",
  },
  keymaps = {
    ["ov"] = { "actions.select", opts = { vertical = true, split = "botright" } },
    ["oh"] = { "actions.select", opts = { horizontal = true } },
    ["g?"] = { "actions.show_help", mode = "n" },
    ["<CR>"] = "actions.select",
    ["<C-p>"] = "actions.preview",
    ["<C-c>"] = { "actions.close", mode = "n" },
    ["<C-l>"] = "actions.refresh",
    ["-"] = { "actions.parent", mode = "n" },
    ["_"] = { "actions.open_cwd", mode = "n" },
    ["`"] = { "actions.cd", mode = "n" },
    ["gs"] = { "actions.change_sort", mode = "n" },
    ["gx"] = "actions.open_external",
    ["g."] = { "actions.toggle_hidden", mode = "n" },
    ["g\\"] = { "actions.toggle_trash", mode = "n" },
  },
})

vim.keymap.set("n", "<leader>o", "<cmd>Oil<cr>", { noremap = true, silent = true })
