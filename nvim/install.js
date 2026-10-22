#!/usr/bin/env bun

import { $ } from "bun";

const PREREQUISITES = ["git", "curl", "tar", "make", "go", "node"];

const TOOLS = [
  { bin: "tree-sitter", brew: "tree-sitter-cli", pacman: "tree-sitter-cli" },
  { bin: "rg", brew: "ripgrep", pacman: "ripgrep" },
  { bin: "stylua", brew: "stylua", pacman: "stylua" },
  {
    bin: "lua-language-server",
    brew: "lua-language-server",
    pacman: "lua-language-server",
  },
  { bin: "magick", brew: "imagemagick", pacman: "imagemagick" },
  { bin: "gs", brew: "ghostscript", pacman: "ghostscript" },
  { bin: "tectonic", brew: "tectonic", pacman: "tectonic" },
];

const GO_TOOLS = [
  { bin: "gopls", pkg: "golang.org/x/tools/gopls@latest" },
  { bin: "dlv", pkg: "github.com/go-delve/delve/cmd/dlv@latest" },
];

const REGISTRY = `${import.meta.dir}/registry/js`;

function step(msg) {
  console.log(`\n==> ${msg}`);
}

// 1. prerequisites
const missingPrereqs = PREREQUISITES.filter((bin) => !Bun.which(bin));
if (missingPrereqs.length > 0) {
  console.error(`Missing prerequisites: ${missingPrereqs.join(", ")}`);
  process.exit(1);
}

// nvim-treesitter compiles parsers with $CC, falling back to cc
const compiler = Bun.env.CC ?? "cc";
if (!Bun.which(compiler)) {
  console.error(
    `Missing C compiler "${compiler}" (macOS: xcode-select --install, Arch: sudo pacman -S --needed --noconfirm base-devel)`,
  );
  process.exit(1);
}

// 2. system tools
const missing = TOOLS.filter((t) => !Bun.which(t.bin));
step(`System tools (${missing.length} missing)`);

if (missing.length > 0) {
  switch (process.platform) {
    case "darwin": {
      await $`brew install ${missing.map((t) => t.brew)}`;
      break;
    }
    case "linux": {
      const repo = missing.flatMap((t) => (t.pacman ? [t.pacman] : []));
      const aur = missing.flatMap((t) => (t.aur ? [t.aur] : []));

      if (repo.length > 0) {
        await $`sudo pacman -S --needed --noconfirm ${repo}`;
      }
      if (aur.length > 0) {
        const helper = ["yay"].find((h) => Bun.which(h));
        if (helper) {
          await $`${helper} -S --needed --noconfirm ${aur}`;
        } else {
          console.warn(
            `No AUR helper found, install manually: ${aur.join(", ")}`,
          );
        }
      }
      break;
    }
    default:
      console.error(`Unsupported platform: ${process.platform}`);
      process.exit(1);
  }
}

// 3. go tools
const missingGo = GO_TOOLS.filter((t) => !Bun.which(t.bin));
step(`Go tools (${missingGo.length} missing)`);
for (const t of missingGo) {
  await $`go install ${t.pkg}`;
}

// 4. js language servers
step("JS language servers");
await $`bun install --frozen-lockfile`.cwd(REGISTRY);

step("Done.");
