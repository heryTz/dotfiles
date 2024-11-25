vim.cmd([[
  augroup DockerfileDetection
    autocmd!
    autocmd BufRead,BufNewFile Dockerfile* set filetype=dockerfile
  augroup END
]])
