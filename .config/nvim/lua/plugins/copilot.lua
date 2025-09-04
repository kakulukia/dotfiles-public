-- ~/.config/nvim/lua/plugins/copilot.lua
return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  build = ":Copilot auth",
  event = "InsertEnter",
  config = function()
    require("copilot").setup({
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = "<Right>", -- Vorschlag annehmen mit Pfeil nach rechts
          next = "<C-Right>", -- nächster Vorschlag mit Strg + Pfeil nach rechts
          prev = "<C-Left>", -- vorheriger Vorschlag mit Strg + Pfeil nach links
          dismiss = "<Esc>", -- Vorschlag ausblenden mit Esc
        },
      },
      panel = { enabled = false },
    })
  end,
}
