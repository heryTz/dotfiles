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

-- Go {{{
require("dap-go").setup()
-- }}}

-- Lua {{{
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
-- }}}

-- JavaScript / TypeScript {{{
local js_dap_debug_server = (vim.env.NVIM_REGISTRY or vim.fn.stdpath("config") .. "/registry")
  .. "/js-debug/src/dapDebugServer.js"

local function playwright_chromium()
  local is_mac = vim.uv.os_uname().sysname == "Darwin"
  local cache = vim.env.PLAYWRIGHT_BROWSERS_PATH
    or vim.fs.normalize(is_mac and "~/Library/Caches/ms-playwright" or "~/.cache/ms-playwright")
  local bin = is_mac and "chrome-mac*/Google Chrome for Testing.app/Contents/MacOS/Google Chrome for Testing"
    or "chrome-linux*/chrome"
  local found = vim.fn.glob(cache .. "/chromium-*/" .. bin, false, true)
  -- highest version wins
  table.sort(found, function(a, b)
    return tonumber(a:match("chromium%-(%d+)")) < tonumber(b:match("chromium%-(%d+)"))
  end)
  return found[#found]
end

local js_adapter = {
  type = "server",
  host = "localhost",
  port = "${port}",
  executable = {
    command = "node",
    args = { js_dap_debug_server, "${port}" },
  },
  -- Do what VS Code does for js-debug: set __workspaceFolder (else outFiles is ignored)
  -- and make `program` absolute (else program: "x.ts" isn't mapped to its compiled .js).
  enrich_config = function(config, on_config)
    config = vim.deepcopy(config)
    config.__workspaceFolder = config.__workspaceFolder or vim.fn.getcwd()
    local program = config.program
    if type(program) == "string" and program ~= "" and not vim.startswith(program, "/") then
      config.program = vim.fs.normalize(vim.fs.joinpath(config.cwd or config.__workspaceFolder, program))
    end
    if config.type == "pwa-chrome" and config.request == "launch" and not config.runtimeExecutable then
      config.runtimeExecutable = playwright_chromium()
    end
    on_config(config)
  end,
}

dap.adapters["pwa-node"] = js_adapter
dap.adapters["pwa-chrome"] = js_adapter

for vscode_type, js_type in pairs({ node = "pwa-node", chrome = "pwa-chrome" }) do
  dap.adapters[vscode_type] = function(cb, config)
    config.type = js_type
    cb(js_adapter)
  end
end

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
  }
end

-- More information about vscode dap configurations
-- https://github.com/microsoft/vscode-js-debug/blob/main/OPTIONS.md
-- https://code.visualstudio.com/docs/nodejs/nodejs-debugging#_launch-configuration-attributes
-- }}}

-- Keymaps {{{
vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint)
vim.keymap.set("n", "<leader>dc", dap.continue)
vim.keymap.set("n", "<leader>dt", dap.terminate)
vim.keymap.set("n", "<leader>dl", function()
  require("osv").launch({ port = 8086 })
end)
-- }}}

-- UI: open/close dap-ui with the session {{{
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
-- }}}
