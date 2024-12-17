return {
	"hrsh7th/nvim-cmp",
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-path",
		"L3MON4D3/LuaSnip",
		"saadparwaiz1/cmp_luasnip",
	},
	opts = function(_, opts)
		opts.sources = opts.sources or {}
		table.insert(opts.sources, {
			name = "lazydev",
			group_index = 0,
		})
	end,
	config = function()
		local cmp = require("cmp")
		local cmp_select = { behavior = cmp.SelectBehavior.Select }

		cmp.setup({
			snippet = {
				expand = function(args)
					require("luasnip").lsp_expand(args.body)
				end,
			},
			window = {
				completion = cmp.config.window.bordered(),
				documentation = cmp.config.window.bordered(),
			},
			mapping = cmp.mapping.preset.insert({
				["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
				["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
				["<C-Space>"] = cmp.mapping.complete(),
				["<C-e>"] = cmp.mapping.abort(),
				["<CR>"] = cmp.mapping.confirm({ select = true }),
			}),
			sources = cmp.config.sources({
				{ name = "nvim_lsp" },
				{ name = "luasnip" },
				{ name = "path" },
			}, {
				{ name = "buffer" },
			}),
			formatting = {
				fields = { "abbr", "kind", "menu" },
				expandable_indicator = true,
				format = function(entry, vim_item)
					vim_item.menu = ({
						nvim_lsp = "[lsp]",
						luasnip = "[snip]",
						path = "[path]",
						buffer = "[buf]",
					})[entry.source.name]
					return vim_item
				end,
			},
		})
	end,
}
