vim.pack.add({
  "https://github.com/L3MON4D3/LuaSnip",
  {
    src = "https://github.com/saghen/blink.cmp",
    version = vim.version.range("1.0"),
  },
  "https://github.com/neovim/nvim-lspconfig",
})

local blink = require("blink.cmp")
blink.setup({
  keymap = { preset = "default" },
  appearance = {
    nerd_font_variant = "mono",
  },
  completion = {
    menu = {
      border = "rounded",
    },
    documentation = {
      auto_show = false,
      window = {
        border = "rounded",
      },
    },
  },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },
  fuzzy = { implementation = "prefer_rust_with_warning" },
  snippets = { preset = "luasnip" },
})

local lsp = {
  "lua_ls",
  "tailwindcss",
  "eslint",
  "cssls",
  "css_variables",
  "gopls",
  "jsonls",
  "biome",
  --TODO: does not support `bun:test` then remove `vtsls`
  -- "tsc",
}

local capabilities = blink.get_lsp_capabilities()

for _, lsp_name in ipairs(lsp) do
  vim.lsp.enable(lsp_name)
  vim.lsp.config(lsp_name, {
    capabilities = capabilities,
  })
end

-- typescript
local registry_path = vim.fn.expand("~/prog/third/nvim-registry/node")
vim.lsp.config("vtsls", {
  capabilities = capabilities,
  settings = {
    vtsls = {
      tsserver = {
        globalPlugins = {
          {
            name = "@vue/typescript-plugin",
            location = registry_path .. "/node_modules/@vue/language-server",
            languages = { "vue" },
            configNamespace = "typescript",
          },
        },
      },
    },
  },
  filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
})
vim.lsp.config("vue_ls", {
  capabilities = capabilities,
})
vim.lsp.enable({ "vtsls", "vue_ls" })

-- keymaps
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    vim.keymap.set("n", "gd", require("telescope.builtin").lsp_definitions)
    vim.keymap.set("n", "gr", require("telescope.builtin").lsp_references)
    vim.keymap.set("n", "gt", require("telescope.builtin").lsp_type_definitions)
    vim.keymap.set("n", "K", function()
      vim.lsp.buf.hover({
        border = "rounded",
      })
    end)
    vim.keymap.set("n", "gK", vim.lsp.buf.signature_help)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)
    vim.keymap.set("n", "<leader>gs", require("telescope.builtin").lsp_document_symbols)

    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client == nil then
      return
    end

    if client:supports_method("textDocument/rename") then
      vim.keymap.set("n", "<leader>br", vim.lsp.buf.rename)
    end

    if client:supports_method("textDocument/implementation") then
      vim.keymap.set("n", "gI", require("telescope.builtin").lsp_implementations)
    end

    if client:supports_method("textDocument/declaration") then
      vim.keymap.set("n", "gD", vim.lsp.buf.declaration)
    end
  end,
})
