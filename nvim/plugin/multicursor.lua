vim.pack.add({
  {
    src = "https://github.com/jake-stewart/multicursor.nvim",
    version = "1.0",
  },
})

local mc = require("multicursor-nvim")
mc.setup()

vim.keymap.set({ "n", "x" }, "<C-up>", function()
  mc.lineAddCursor(-1)
end)
vim.keymap.set({ "n", "x" }, "<C-down>", function()
  mc.lineAddCursor(1)
end)

-- TODO: "<up>" and "<down>" does not work properly
-- vim.keymap.set({ "n", "x" }, "<C-up>", function()
--   mc.lineSkipCursor(-1)
-- end)
-- vim.keymap.set({ "n", "x" }, "<C-down>", function()
--   mc.lineSkipCursor(1)
-- end)

vim.keymap.set({ "n", "x" }, "<leader>N", function()
  mc.matchAddCursor(-1)
end)
vim.keymap.set({ "n", "x" }, "<leader>S", function()
  mc.matchSkipCursor(-1)
end)
vim.keymap.set({ "n", "x" }, "<leader>n", function()
  mc.matchAddCursor(1)
end)
vim.keymap.set({ "n", "x" }, "<leader>s", function()
  mc.matchSkipCursor(1)
end)

vim.keymap.set({ "n", "x" }, "<leader>A", function()
  mc.matchAllAddCursors()
end)

vim.keymap.set({ "n", "x" }, "<C-q>", mc.toggleCursor)

vim.keymap.set("x", "I", mc.insertVisual)
vim.keymap.set("x", "I", mc.appendVisual)

mc.addKeymapLayer(function(layerSet)
  layerSet({ "n", "x" }, "<up>", mc.prevCursor)
  layerSet({ "n", "x" }, "<down>", mc.nextCursor)
  layerSet({ "n", "x" }, "<leader>x", mc.deleteCursor)
  layerSet("n", "<esc>", function()
    if not mc.cursorsEnabled() then
      mc.enableCursors()
    else
      mc.clearCursors()
    end
  end)
end)
