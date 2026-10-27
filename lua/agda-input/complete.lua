local M = {}

local flat = {}
for key, translations in pairs(require("agda-input.data")) do
  for _, symbol in ipairs(translations) do
    flat[#flat + 1] = { key = key, symbol = symbol }
  end
end

function M.complete(findstart, base)
  -- locate the start of the "word" (the last backslash before cursor)
  if findstart == 1 then
    local line = vim.api.nvim_get_current_line()
    local col  = vim.api.nvim_win_get_cursor(0)[2] -- 0-based byte column
    for i = col, 1, -1 do
      if line:sub(i, i) == "\\" then
        return i - 1  -- 0-based byte column of the backslash
      end
    end
    return -1
  end

  -- return items whose key starts with the typed text (e.g. "\=", "\lambd")
  local items = {}
  for _, e in ipairs(flat) do
    if vim.startswith(e.key, base) then
      items[#items + 1] = {
        word       = e.symbol,
        filtertext = e.key,
        abbr       = e.key .. "  " .. e.symbol,
        menu       = "[Agda]",
        info       = e.symbol,
      }
    end
  end
  return items
end

return M
