vim.cmd([[
  augroup DockerfileDetection
    autocmd!
    autocmd BufRead,BufNewFile Dockerfile* set filetype=dockerfile
  augroup END
]])

vim.filetype.add({
	extension = {
		gotmpl = "gotmpl",
	},
	pattern = {
		[".*/templates/.*%.tpl"] = "helm",
		[".*/templates/.*%.ya?ml"] = "helm",
		["helmfile.*%.ya?ml"] = "helm",
	},
})
