-- Mason setup
require("mason").setup()

-- Mason LSP config bridge
require("mason-lspconfig").setup({
	ensure_installed = { "lua_ls", "pyright", "gopls", "bashls", "clangd", "ts_ls" },
	automatic_enable = { "lua_ls", "pyright", "gopls", "bashls", "clangd", "ts_ls" },
})
