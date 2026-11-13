# Debugging Node.js & TypeScript (js-debug)

Ready-to-use `launch.json` configs for debugging Node.js/TypeScript with js-debug, in VS Code or Neovim (nvim-dap).

## References

- [Node.js debugging](https://code.visualstudio.com/docs/nodejs/nodejs-debugging)
- [Config references](https://github.com/microsoft/vscode-js-debug/blob/main/OPTIONS.md)

## Configurations

Adjusts to fit your needs.

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Launch program",
      "program": "${workspaceFolder}/src/index.ts",
      "cwd": "${workspaceFolder}",
      "outFiles": [
        "${workspaceFolder}/dist/**/*.js"
      ],
    },
    {
      "type": "node",
      "request": "launch",
      "name": "npm debug",
      "runtimeExecutable": "npm",
      "runtimeArgs": [
        "run-script",
        "debug"
      ],
      "cwd": "${workspaceFolder}",
      "outFiles": [
        "${workspaceFolder}/dist/**/*.js"
      ]
    },
    {
      "type": "node",
      "request": "attach",
      "name": "Attach to server",
      "port": 9229,
      "cwd": "${workspaceFolder}",
      "outFiles": [
        "${workspaceFolder}/dist/**/*.js"
      ],
    },
    {
      "type": "chrome",
      "request": "launch",
      "name": "Launch chrome",
      "url": "http://localhost:5173",
      "webRoot": "${workspaceFolder}"
    }
  ]
}
```

## Useful Options

### outFiles

By default, VS Code Debug search our entire project and excluding `node_modules`. This option configure where the compiled `.js` are.

js-debug reads their source maps to link them to your `.ts` files, so breakpoints work and `program` can point to a `.ts` file.

### resolveSourceMapLocations

By default, VS Code Debug resolve the outFiles maps but sometimes, we need to step into a library's original TypeScript.

```json
"resolveSourceMapLocations": [
  "${workspaceFolder}/**",
  "!**/node_modules/**",
  "${workspaceFolder}/node_modules/some-lib/**"
]

```
