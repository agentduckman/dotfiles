-- mappings, including plugins

local function map(m, k, v, opts)
	opts = vim.tbl_extend("force", { noremap = true, silent = true }, opts or {})
	vim.keymap.set(m, k, v, opts)
end

-- set leader
map("", "<Space>", "<Nop>")
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Yazi
map("n", "<leader>y", ":Yazi<CR>")

-- buffers
map("n", "<S-l>", ":BufferNext<CR>")
map("n", "<S-h>", ":BufferPrevious<CR>")
map("n", "<leader>bd", ":BufferClose<CR>")
map("n", "<leader>bn", ":enew<CR>")
map("n", "<leader>bp", ":BufferPin<CR>")
map("n", "<leader>bo", ":BufferCloseAllButCurrent<CR>")
map("n", "<leader>bL", ":BufferMoveNext<CR>")
map("n", "<leader>bH", ":BufferMovePrevious<CR>")

-- Venv select
map('n', '<leader>v', ':VenvSelect<CR>') --ver split + open next buffer

-- Tmux Navigator keymaps
vim.keymap.set("n", "<C-h>", "<cmd><C-U>TmuxNavigateLeft<CR>", { silent = true })
vim.keymap.set("n", "<C-j>", "<cmd><C-U>TmuxNavigateDown<CR>", { silent = true })
vim.keymap.set("n", "<C-k>", "<cmd><C-U>TmuxNavigateUp<CR>", { silent = true })
vim.keymap.set("n", "<C-l>", "<cmd><C-U>TmuxNavigateRight<CR>", { silent = true })
vim.keymap.set("n", "<C-\\>", "<cmd><C-U>TmuxNavigatePrevious<CR>", { silent = true })


-- windows - tmux-aware ctrl nav, fn resize
map("n", "<F5>", ":resize +2<CR>")
map("n", "<F6>", ":resize -2<CR>")
map("n", "<F7>", ":vertical resize +2<CR>")
map("n", "<F8>", ":vertical resize -2<CR>")

-- fzf and grep
map("n", "<leader>f", ":lua require('fzf-lua').files()<CR>")                       --search cwd
map("n", "<leader>Fh", ":lua require('fzf-lua').files({ cwd = '~/' })<CR>")        --search home
map("n", "<leader>Fc", ":lua require('fzf-lua').files({ cwd = '~/.config' })<CR>") --search .config
map("n", "<leader>Fl", ":lua require('fzf-lua').files({ cwd = '/etc' })<CR>")      --search .local/src
map("n", "<leader>Ff", ":lua require('fzf-lua').files({ cwd = '..' })<CR>")        --search above
map("n", "<leader>g", ":lua require('fzf-lua').live_grep()<CR>")                   --grep

-- LSP and diagnostics
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local opts = { buffer = args.buf }
		map("n", "gd", vim.lsp.buf.definition, opts)
		map("n", "gD", vim.lsp.buf.declaration, opts)
		map("n", "gr", vim.lsp.buf.references, opts)
		map("n", "gi", vim.lsp.buf.implementation, opts)
		map("n", "K", vim.lsp.buf.hover, opts)
		map("n", "<leader>rn", vim.lsp.buf.rename, opts)
		map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
	end,
})

map("n", "[d", vim.diagnostic.goto_prev)
map("n", "]d", vim.diagnostic.goto_next)
map("n", "<leader>df", vim.diagnostic.open_float)
map("n", "<leader>dl", vim.diagnostic.setloclist)
map("n", "<leader>dv", function()
	local current = vim.diagnostic.config().virtual_text
	vim.diagnostic.config({ virtual_text = not current })
end)
map("n", "<leader>dd", ":Trouble diagnostics toggle filter.buf=0<CR>")

-- Trouble
map("n", "<leader>xx", ":Trouble diagnostics toggle<CR>")
map("n", "<leader>xX", ":Trouble diagnostics toggle filter.buf=0<CR>")
map("n", "<leader>xq", ":Trouble qflist toggle<CR>")
map("n", "<leader>xl", ":Trouble loclist toggle<CR>")
map("n", "<leader>xr", ":Trouble lsp_references toggle<CR>")

-- formatting and linting
map("n", "<leader>lf", ":Format<CR>")
map("n", "<leader>ll", function()
	require("lint").try_lint()
end)

-- git
map("n", "]h", function()
	require("gitsigns").nav_hunk("next")
end)
map("n", "[h", function()
	require("gitsigns").nav_hunk("prev")
end)
map("n", "<leader>hp", function()
	require("gitsigns").preview_hunk()
end)
map("n", "<leader>hi", function()
	require("gitsigns").preview_hunk_inline()
end)
map("n", "<leader>hs", function()
	require("gitsigns").stage_hunk()
end)
map("v", "<leader>hs", function()
	require("gitsigns").stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
end)
map("n", "<leader>hr", function()
	require("gitsigns").reset_hunk()
end)
map("v", "<leader>hr", function()
	require("gitsigns").reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
end)
map("n", "<leader>hb", function()
	require("gitsigns").blame_line({ full = true })
end)

-- misc
map("n", "<leader>e", ":NvimTreeToggle<CR>")                          --open file explorer
map("n", "<leader>ef", ":NvimTreeFindFile<CR>")
map("n", "<leader>er", ":NvimTreeRefresh<CR>")
map("n", "<leader>ec", ":NvimTreeCollapse<CR>")
map("n", "<leader>ee", ":NvimTreeFocus<CR>")
map("n", "<leader>P", ":PlugInstall<CR>")                             --vim-plug
map('n', '<leader>t', ":lua require('FTerm').open()<CR>")             --open term
map('t', '<Esc>', '<C-\\><C-n><CMD>lua require("FTerm").close()<CR>') --preserves session
map("n", "<leader>mx", "<cmd>!chmod +x %<CR>")                        --make a file executable
map("n", "<leader>R", ":so %<CR>")                                    --reload neovim config
map("n", "<leader>W", ":set wrap!<CR>")                               --toggle wrap
map("n", "<leader>ch", ":checkhealth<CR>")
map("n", "<leader>ss", ":setlocal spell!<CR>")
map("n", "<leader>Ci", ":e ~/.config/nvim/init.lua<CR>")
map("n", "<leader>Cm", ":e ~/.config/nvim/lua/config/mappings.lua<CR>")
map("n", "<leader>Co", ":e ~/.config/nvim/lua/config/options.lua<CR>")
map("n", "<leader>Cp", ":e ~/.config/nvim/lua/plugins/<CR>")

-- decisive csv
map("n", "<leader>csa", ":lua require('decisive').align_csv({})<cr>")
map("n", "<leader>csA", ":lua require('decisive').align_csv_clear({})<cr>")
map("n", "[c", ":lua require('decisive').align_csv_prev_col()<cr>")
map("n", "]c", ":lua require('decisive').align_csv_next_col()<cr>")





map("n", "<leader>nn", function() --toggle relative vs absolute line numbers
	if vim.wo.relativenumber then
		vim.wo.relativenumber = false
		vim.wo.number = true
	else
		vim.wo.relativenumber = true
	end
end)
