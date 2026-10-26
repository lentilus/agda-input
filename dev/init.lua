require("cmp").register_source("agda_input", require("agda-input.cmp"))

local cmp = require("cmp")

cmp.setup({
  sources = { { name = "agda_input" }},
  mapping = cmp.mapping.preset.insert({
    ["<Space>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.confirm({ select = true, behavior = cmp.ConfirmBehavior.Replace })
        return " "  -- space after accepting
      end
      fallback()
    end, { "i" }),
  }),
})

vim.o.completeopt = "menuone,noselect"

vim.cmd([[
  enew
  setlocal buftype=nofile bufhidden=wipe
  call setline(1, ['To test completions: type \to, \lambda, ... '])
]])
