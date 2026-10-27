local M = {}

local flat = {}
for key, translations in pairs(require("agda-input.data")) do
  for _, symbol in ipairs(translations) do
    flat[#flat + 1] = { key = key, symbol = symbol }
  end
end

function M.complete(findstart, base)
  if findstart == 1 then
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    for i = col, 1, -1 do
      if line:sub(i, i) == "\\" then
        return i - 1
      end
    end
    return -1
  end

  local base_len = #base
  local items    = {}
  for idx, e in ipairs(flat) do
    if e.key:sub(1, base_len) == base then
      items[#items + 1] = {
        word = e.key,
        abbr = e.symbol .. "  " .. e.key,
        menu = "[Agda]",
        dup = 1, -- make sure we get all options
        user_data = { agda_symbol = e.symbol },
        _missing = #e.key - base_len,
        _idx = idx,
      }
    end
  end

  table.sort(items, function(a, b)
    if a._missing ~= b._missing then
      return a._missing < b._missing
    end
    if a.word ~= b.word then
      return a.word < b.word
    end
    return a._idx < b._idx -- stable order within a key's symbols
  end)

  for _, item in ipairs(items) do
    item._missing = nil
    item._idx = nil
  end

  return items
end

return M
