# Awesome VS Code Debug Configuration

TODO: improve

- [https://github.com/microsoft/vscode-js-debug/blob/main/OPTIONS.md]
- [https://code.visualstudio.com/docs/nodejs/nodejs-debugging#_launch-configuration-attributes]

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "name": "Launch typeScript",
      "request": "launch",
      "program": "src/test.ts",
      "outFiles": [
        "${workspaceFolder}/dist/**/*.js"
      ]
    },
    {
      "type": "node",
      "request": "launch",
      "name": "Debug server (sourcemap)",
      "program": "${workspaceFolder}/src/index.ts",
      "outFiles": [
        "${workspaceFolder}/dist/**/*.js"
      ],
      "cwd": "${workspaceFolder}"
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
      ],
      "resolveSourceMapLocations": [
        "${workspaceFolder}/**",
        "!**/node_modules/**"
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
      "resolveSourceMapLocations": [
        "${workspaceFolder}/**",
        "!**/node_modules/**"
      ]
    }
  ]
}

```

```lua
    {
        type = "pwa-node",
        request = "attach",
        name = "Attach to process [2]",
        processId = require("dap.utils").pick_process,
        cwd = "${workspaceFolder}",
        outFiles = { "${workspaceFolder}/dist/**/*.js" },
        resolveSourceMapLocations = { "${workspaceFolder}/**", "!**/node_modules/**" },
    }
```
