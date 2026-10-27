-- Global bridge so `v:lua.__agda_complete` resolves reliably
_G.__agda_complete = function(findstart, base)
  return require("agda-input.complete").complete(findstart, base)
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function(args)
    vim.api.nvim_set_option_value(
      "completefunc", "v:lua.__agda_complete", { buf = args.buf }
    )
  end,
})

vim.cmd([[
  enew
  setlocal buftype=nofile bufhidden=wipe
  call setline(1, ['To test completions: type \to, \lambda, ... '])
]])
