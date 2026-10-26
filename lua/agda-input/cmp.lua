local source = {}

function source.new() return setmetatable({}, { __index = source }) end
function source:is_available() return true end
function source:get_trigger_characters() return { "\\" } end
function source:get_keyword_pattern() return [[\\\S*]] end

function source:complete(_, callback)
  local items = {}
  for key, translations in pairs(require("agda-input.data")) do
    for _, t in ipairs(translations) do
      items[#items + 1] = {
        label        = key,            -- "\to"
        labelDetails = { detail = t }, -- "→"  (dimmed, after label)
        filterText   = key,
        insertText   = t,              -- accept replaces "\to" with "→"
      }
    end
  end
  callback({ items = items, isIncomplete = false })
end

return source
