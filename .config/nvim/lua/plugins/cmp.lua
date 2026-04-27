-- nvim-cmp setup (completion UI)
local cmp = require("cmp")

cmp.setup({
	mapping = cmp.mapping.preset.insert({
		['<C-Space>'] = cmp.mapping.complete(), -- trigger completion menu
		['<CR>'] = cmp.mapping.confirm({ select = true }), -- confirm selection
		['<Tab>'] = cmp.mapping.select_next_item(), -- next suggestion
		['<S-Tab>'] = cmp.mapping.select_prev_item(), -- previous suggestion
	}),
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		{ name = 'buffer' },
		{ name = 'path' },
	}),
	completion = {
		completeopt = 'menu,menuone,noinsert',
	},
})
