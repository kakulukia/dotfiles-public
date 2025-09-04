-- Ensure Pug parser is always installed by nvim-treesitter
return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    -- make sure opts exists
    opts = opts or {}

    -- auto_install helps when you open a .pug file on a new machine
    opts.auto_install = true

    -- normalize ensure_installed to a table and inject "pug"
    local ensure = opts.ensure_installed or {}
    if ensure == "all" then
      -- nothing to do, all parsers will be installed
      opts.ensure_installed = ensure
      return opts
    end
    if type(ensure) == "string" then
      ensure = { ensure }
    end

    -- add "pug" if it's not already present
    local has_pug = false
    for _, lang in ipairs(ensure) do
      if lang == "pug" then
        has_pug = true
        break
      end
    end
    if not has_pug then
      table.insert(ensure, "pug")
    end

    opts.ensure_installed = ensure
    return opts
  end,
}
