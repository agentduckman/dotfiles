require("conform").setup({
  formatters_by_ft = {
    python = { "ruff_format" }, -- or { "ruff_fix", "ruff_format" } (see below)
  },

  -- Optional: format on save
  format_on_save = {
    timeout_ms = 2000,
    lsp_format = "fallback",
  },
})

-- On-demand command
vim.api.nvim_create_user_command("Format", function()
  require("conform").format({ async = false, lsp_format = "fallback" })
end, {})
