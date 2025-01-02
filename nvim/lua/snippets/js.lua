local ls = require("luasnip")
local l = require("luasnip.extras").lambda

local str = require("../util/string")

local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

ls.add_snippets("typescriptreact", {
	s("cmp", {
		t({ "export function " }),
		f(function(_, snip)
			return str.toPascalCase(snip.env.TM_FILENAME_BASE)
		end, {}),
		t({ "() {", "\t" }),
		t({ "return <div>" }),
		i(1),
		t({ "</div>", "}" }),
	}),

	s("cmpp", {
		t({ "export function " }),
		f(function(_, snip)
			return str.toPascalCase(snip.env.TM_FILENAME_BASE)
		end, {}),
		t({ "({  }: " }),
		f(function(_, snip)
			return str.toPascalCase(snip.env.TM_FILENAME_BASE) .. "Props"
		end, {}),
		t({ ") {", "\t" }),
		t({ "return <div>" }),
		i(1),
		t({ "</div>", "}", "", "" }),
		t({ "type " }),
		f(function(_, snip)
			return str.toPascalCase(snip.env.TM_FILENAME_BASE) .. "Props"
		end, {}),
		t({ " = {", "\t" }),
		i(2),
		t({ "", "}", "" }),
	}),

	s("cmppc", {
		t({ 'import { PropsWithChildren } from "react"', "", "" }),
		t({ "export function " }),
		f(function(_, snip)
			return str.toPascalCase(snip.env.TM_FILENAME_BASE)
		end, {}),
		t({ "({ children }: " }),
		f(function(_, snip)
			return str.toPascalCase(snip.env.TM_FILENAME_BASE) .. "Props"
		end, {}),
		t({ ") {", "\t" }),
		t({ "return <div>" }),
		i(1),
		t({ "</div>", "}", "", "" }),
		t({ "type " }),
		f(function(_, snip)
			return str.toPascalCase(snip.env.TM_FILENAME_BASE) .. "Props"
		end, {}),
		t({ " = PropsWithChildren<{", "\t" }),
		i(2),
		t({ "", "}>", "" }),
	}),
})
