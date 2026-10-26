local M = {}
M.data = require("agda-input.data")

local function insert_opts(opts)
  if #opts == 1 then
    return opts[1]
  end
  
  -- Multiple translations: show native completion popup.
  vim.fn.complete(vim.fn.col("."), opts)
  return ""
end

function M.setup(opts)
  opts = opts or {}

  for key, translations in pairs(M.data) do
    vim.keymap.set("i", key, function()
      return insert_opts(translations)
    end, {
      expr = true,
      buffer = opts.buffer,
      silent = true,
      desc = "Agda input: " .. key,
    })
  end
end

return M
