vim.pack.add({
  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/nvim-lualine/lualine.nvim",
})

require("lualine").setup({
  sections = {
    lualine_b = {
      {
        "branch",
        fmt = function(str)
          local max = 20
          if vim.fn.strchars(str) > max then
            return vim.fn.strcharpart(str, 0, max - 3) .. "..."
          end
          return str
        end,
      },
      "diff",
      "diagnostics",
    },
    lualine_c = {
      {
        "filename",
        path = 1,
      },
    },
    lualine_x = { "filetype" },
  },
  inactive_sections = {
    lualine_c = {
      {
        "filename",
        path = 1,
      },
    },
  },
})
