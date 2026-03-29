local ls = require("luasnip")

local str = require("../util/string")

local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

local function component_name(_, snip)
	return str.toPascalCase(snip.env.TM_FILENAME_BASE)
end

local function props_type(_, snip)
	return str.toPascalCase(snip.env.TM_FILENAME_BASE) .. "Props"
end

ls.add_snippets("typescriptreact", {
	s("cmp", {
		t({ "export function " }),
		f(component_name, {}),
		t({ "() {", "\t" }),
		t({ "return <div>" }),
		i(1),
		t({ "</div>", "}" }),
	}),

	s("cmpp", {
		t({ "export function " }),
		f(component_name, {}),
		t({ "({  }: " }),
		f(props_type, {}),
		t({ ") {", "\t" }),
		t({ "return <div>" }),
		i(1),
		t({ "</div>", "}", "", "" }),
		t({ "type " }),
		f(props_type, {}),
		t({ " = {", "\t" }),
		i(2),
		t({ "", "}", "" }),
	}),

	s("cmppc", {
		t({ 'import { PropsWithChildren } from "react"', "", "" }),
		t({ "export function " }),
		f(component_name, {}),
		t({ "({ children }: " }),
		f(props_type, {}),
		t({ ") {", "\t" }),
		t({ "return <div>" }),
		i(1),
		t({ "</div>", "}", "", "" }),
		t({ "type " }),
		f(props_type, {}),
		t({ " = PropsWithChildren<{", "\t" }),
		i(2),
		t({ "", "}>", "" }),
	}),
})
