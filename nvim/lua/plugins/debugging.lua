return {
	{
		"microsoft/vscode-js-debug",
		build = "npm install --legacy-peer-deps --ignore-scripts && npx gulp vsDebugServerBundle && rm -rf out && mv dist out && git restore package-lock.json",
	},
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"leoluz/nvim-dap-go",
			"mxsdev/nvim-dap-vscode-js",
			"jbyuki/one-small-step-for-vimkind",
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			dapui.setup()
			require("dap-go").setup()

			---@diagnostic disable-next-line: missing-fields
			-- require("dap-vscode-js").setup({
			-- 	debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
			-- 	adapters = { "pwa-node" },
			-- })

			---dap configs
			-- local js_filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" }
			--
			-- for _, js_language in ipairs(js_filetypes) do
			-- 	dap.configurations[js_language] = {
			-- 		{
			-- 			type = "pwa-node",
			-- 			request = "launch",
			-- 			name = "Launch file",
			-- 			program = "${file}",
			-- 			cwd = "${workspaceFolder}",
			-- 		},
			-- 		{
			-- 			type = "pwa-node",
			-- 			request = "attach",
			-- 			name = "Attach to process",
			-- 			processId = require("dap.utils").pick_process,
			-- 			cwd = "${workspaceFolder}",
			-- 		},
			-- 		{
			-- 			type = "pwa-node",
			-- 			name = "Launch via npm",
			-- 			request = "launch",
			-- 			cwd = "${workspaceFolder}",
			-- 			runtimeExecutable = "npm",
			-- 			runtimeArgs = {
			-- 				"run-script",
			-- 				"debug",
			-- 			},
			-- 		},
			-- 		{
			-- 			type = "pwa-node",
			-- 			name = "Launch via tsx",
			-- 			request = "launch",
			-- 			cwd = "${workspaceFolder}",
			-- 			runtimeExecutable = "tsx",
			-- 			runtimeArgs = {
			-- 				"${file}",
			-- 			},
			-- 		},
			-- 	}
			-- end

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
		end,
	},
}
