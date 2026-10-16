vim.pack.add({
  "https://github.com/echasnovski/mini.pairs",
  "https://github.com/echasnovski/mini.surround",
})

require("mini.pairs").setup()

require("mini.surround").setup({
  mappings = {
    add = "gsa",
    delete = "gsd",
    find = "gsf",
    find_left = "gsF",
    highlight = "gsh",
    replace = "gsr",
    update_n_lines = "gsn",

    suffix_last = "l",
    suffix_next = "n",
  },
})
