-- Set capabilities for nvim-cmp (completion support)
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Define LSP server configs (new style)
vim.lsp.config("lua_ls", {
	capabilities = capabilities,
})

vim.lsp.config("bashls", {
	capabilities = capabilities,
	filetypes = { "sh", "bash" },
})

vim.lsp.config("asm-lsp", {
	capabilities = capabilities,
	filetypes = { "asm" },
})

vim.lsp.config("sqls", {
	capabilities = capabilities,
})

vim.lsp.config("pyright", {
	capabilities = capabilities,
})

vim.lsp.config("ts_ls", {
	capabilities = capabilities,
})

vim.lsp.config("clangd", {
	capabilities = capabilities,
})

vim.lsp.config("gopls", {
	capabilities = capabilities,
	on_attach = function(client, bufnr)
		vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
	end,
})

-- Enable the servers
vim.lsp.enable("lua_ls")
vim.lsp.enable("pyright")
vim.lsp.enable("ts_ls")
vim.lsp.enable("gopls")
vim.lsp.enable("bashls")
vim.lsp.enable("clangd")
vim.lsp.enable("sqls")
