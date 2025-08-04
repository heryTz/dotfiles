return {
	{
		"microsoft/vscode-js-debug",
		build = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out && git restore package-lock.json",
	},
	{
		"mxsdev/nvim-dap-vscode-js",
		config = function()
			---@diagnostic disable-next-line: missing-fields
			require("dap-vscode-js").setup({
				debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
				adapters = { "pwa-node" },
			})
		end,
	},
	{
		"leoluz/nvim-dap-go",
		config = function()
			require("dap-go").setup()
		end,
	},
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")
			dapui.setup()

			vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
			vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Start Debugger" })
			vim.keymap.set("n", "<leader>dt", dap.terminate, { desc = "Terminate" })

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

			local js_filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" }

			for _, js_language in ipairs(js_filetypes) do
				dap.configurations[js_language] = {
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
						name = "Launch via npm",
						request = "launch",
						cwd = "${workspaceFolder}",
						runtimeExecutable = "npm",
						runtimeArgs = {
							"run-script",
							"debug",
						},
					},
					{
						type = "pwa-node",
						name = "Launch via tsx",
						request = "launch",
						cwd = "${workspaceFolder}",
						runtimeExecutable = "tsx",
						runtimeArgs = {
							"${file}",
						},
					},
				}
			end
		end,
	},
}
