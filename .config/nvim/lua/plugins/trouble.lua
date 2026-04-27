-- lua/trouble.lua

local ok, trouble = pcall(require, "trouble")
if not ok then
  return
end

trouble.setup({
  win = {
    position = "right",
    size = 50,
  },
  auto_open = false,
  auto_close = false,
  auto_preview = true,
  auto_jump = false,
  keys = {
    q = "close",
    ["<esc>"] = "cancel",
    r = "refresh",
    ["<cr>"] = "jump",
    ["<tab>"] = "jump",
    ["<c-x>"] = "jump_split",
    ["<c-v>"] = "jump_vsplit",
    o = "jump_close",
    P = "toggle_preview",
    p = "preview",
    zM = "fold_close_all",
    zm = "fold_more",
    zR = "fold_open_all",
    zr = "fold_reduce",
    zA = "fold_toggle_recursive",
    za = "fold_toggle",
    k = "prev",
    j = "next",
  },
  use_diagnostic_signs = false,
})
