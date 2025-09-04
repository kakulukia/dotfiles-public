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
        debounce = 75,
        keymap = {
          accept = "<C-Right>", -- Vorschlag annehmen mit Strg + Pfeil nach rechts
          unext = "<C-Up>", -- nächster Vorschlag mit Strg + Pfeil nach oben
          prev = "<C-Down>", -- vorheriger Vorschlag mit Strg + Pfeil nach unten
          dismiss = "<Esc>", -- Vorschlag ausblenden mit Esc
        },
      },
      panel = { enabled = false },
    })
  end,
}
