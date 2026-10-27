_G.__agda_complete = function(findstart, base)
  return require("agda-input.complete").complete(findstart, base)
end

vim.o.completefunc = "v:lua.__agda_complete"
vim.o.completeopt  = "menu,menuone,noselect"

vim.api.nvim_create_autocmd("TextChangedI", {
  buffer = bufnr,
  callback = function()
    if vim.fn.pumvisible() == 1 then return end
    if vim.fn.complete_info({ "mode" }).mode ~= "" then return end

    local line   = vim.api.nvim_get_current_line()
    local col    = vim.api.nvim_win_get_cursor(0)[2]
    local prefix = line:sub(1, col)

    if prefix:find("\\%S*$") then
      local keys = vim.api.nvim_replace_termcodes("<C-x><C-u>", true, false, true)
      vim.api.nvim_feedkeys(keys, "i", false)
    end
  end,
})

vim.api.nvim_create_autocmd("CompleteDone", {
  buffer = bufnr,
  callback = function()
    local item = vim.v.completed_item
    if not (item.user_data and item.user_data.agda_symbol) then return end
    local symbol = item.user_data.agda_symbol
    local word   = item.word or ""

    local row  = vim.api.nvim_win_get_cursor(0)[1]
    local col  = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()

    local start = col - #word
    if line:sub(start + 1, col) ~= word then
      local bs = line:sub(1, col):find("\\%S*$")
      if not bs then return end
      start = bs - 1
    end
    if start < 0 or start > col then return end

    vim.api.nvim_buf_set_lines(0, row - 1, row, false,
      { line:sub(1, start) .. symbol .. line:sub(col + 1) })
    vim.api.nvim_win_set_cursor(0, { row, start + #symbol })
  end,
})

local function accept_or_space()
  if vim.fn.pumvisible() == 1 then
    local info = vim.fn.complete_info({ "items", "selected" })
    local first = info.items[1]
    if first and first.menu == "[Agda]" then
      if info.selected == -1 then
        return "<C-n><C-y>"
      end
      return "<C-y>"
    end
  end
  return " "
end

vim.keymap.set("i", "<Space>", accept_or_space, {
  expr = true,
  replace_keycodes = true,
  buffer = bufnr,
  desc = "Accept Agda completion or insert space",
})

vim.cmd([[
  enew
  setlocal buftype=nofile bufhidden=wipe
  call setline(1, ['Try: \to, \Sigma, \->, \lambda, \~~~'])
]])
