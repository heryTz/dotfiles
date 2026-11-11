vim.pack.add({
  "https://github.com/leoluz/nvim-dap-go",
  "https://github.com/jbyuki/one-small-step-for-vimkind",
  "https://github.com/rcarriga/nvim-dap-ui",
  "https://github.com/nvim-neotest/nvim-nio",
  "https://github.com/mfussenegger/nvim-dap",
})

local dap = require("dap")
local dapui = require("dapui")

dapui.setup()

-- go
require("dap-go").setup()

-- lua
dap.configurations.lua = {
  {
    type = "nlua",
    request = "attach",
    name = "Attach to running Neovim instance",
  },
}
dap.adapters.nlua = function(callback, config)
  callback({ type = "server", host = config.host or "127.0.0.1", port = config.port or 8086 })
end

-- JavaScript
local js_dap_debug_server = (vim.env.NVIM_REGISTRY or vim.fn.stdpath("config") .. "/registry")
  .. "/js-debug/src/dapDebugServer.js"

dap.adapters["pwa-node"] = {
  type = "server",
  host = "localhost",
  port = "${port}",
  executable = {
    command = "node",
    args = { js_dap_debug_server, "${port}" },
  },
}

local js_filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" }
for _, filetype in ipairs(js_filetypes) do
  dap.configurations[filetype] = {
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch file",
      program = "${file}",
      cwd = "${workspaceFolder}",
    },
    {
      type = "pwa-node",
      request = "attach",
      name = "Attach to process",
      processId = require("dap.utils").pick_process,
      cwd = "${workspaceFolder}",
    },
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch via tsx",
      cwd = "${workspaceFolder}",
      runtimeExecutable = "tsx",
      runtimeArgs = {
        "${file}",
      },
    },
  }
end

-- More information about vscode dap configurations
-- https://github.com/microsoft/vscode-js-debug/blob/main/OPTIONS.md
-- https://code.visualstudio.com/docs/nodejs/nodejs-debugging#_launch-configuration-attributes

---keymaps
vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint)
vim.keymap.set("n", "<leader>dc", dap.continue)
vim.keymap.set("n", "<leader>dt", dap.terminate)
vim.keymap.set("n", "<leader>dl", function()
  require("osv").launch({ port = 8086 })
end)

---dap bootstrap
dap.listeners.before.attach.dapui_config = function()
  dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
  dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
  dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
  dapui.close()
end
