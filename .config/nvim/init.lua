-- auto install vim-plug and plugins, if not found
local data_dir = vim.fn.stdpath('data')
if vim.fn.empty(vim.fn.glob(data_dir .. '/site/autoload/plug.vim')) == 1 then
	vim.cmd('silent !curl -fLo ' ..
		data_dir ..
		'/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim')
	vim.o.runtimepath = vim.o.runtimepath
	vim.cmd('autocmd VimEnter * PlugInstall --sync | source $MYVIMRC')
end

local vim = vim
local Plug = vim.fn['plug#']

vim.g.start_time = vim.fn.reltime()
vim.loader.enable() --  SPEEEEEEEEEEED 

vim.call('plug#begin')
Plug('linux-cultist/venv-selector.nvim')
Plug('metalelf0/black-metal-theme-neovim')
Plug('nvim-telescope/telescope.nvim')             -- Finder
Plug('folke/noice.nvim')                          -- Command completion
Plug('rcarriga/nvim-notify')                      -- Fancy notifications
Plug('stevearc/conform.nvim')                     -- Auto Formatter
Plug('MunifTanjim/nui.nvim')
Plug('nvim-lualine/lualine.nvim')                 --statusline
Plug('nvim-tree/nvim-web-devicons')               --pretty icons
Plug('folke/which-key.nvim')                      --mappings popup
Plug('romgrk/barbar.nvim')                        --bufferline
Plug('goolord/alpha-nvim')                        --pretty startup
Plug('mfussenegger/nvim-lint')                    --async linter
Plug('nvim-tree/nvim-tree.lua')                   --file explorer
Plug('windwp/nvim-autopairs')                     --autopairs
Plug('nvim-treesitter/nvim-treesitter')
Plug('lewis6991/gitsigns.nvim')                   --git
Plug('numToStr/Comment.nvim')                     --easier comments
Plug('norcalli/nvim-colorizer.lua')               --color highlight
Plug('ibhagwan/fzf-lua')                          --fuzzy finder and grep
Plug('numToStr/FTerm.nvim')                       --floating terminal
Plug('ron-rs/ron.vim')                            --ron syntax highlighting
Plug('MeanderingProgrammer/render-markdown.nvim') --render md inline
Plug('emmanueltouzery/decisive.nvim')             --view csv files
Plug('folke/twilight.nvim')                       --surrounding dim
Plug('mikavilpas/yazi.nvim')                      --yazi file explorer
Plug('nvim-lua/plenary.nvim')                     --just a yazi dependency
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'L3MON4D3/LuaSnip'
Plug 'christoomey/vim-tmux-navigator'
Plug 'folke/trouble.nvim'
vim.call('plug#end')


require("plugins.mason")
require("plugins.treesitter")
require("plugins.noice")
require("plugins.lsp")
require("plugins.cmp")
require("plugins.black-metal-neovim")
require("config.mappings")
require("config.options")
require("config.autocmd")
require("plugins.trouble")
require("plugins.alpha")
require("plugins.barbar")
require("plugins.colorizer")
require("plugins.comment")
require("plugins.gitsigns")
require("plugins.lualine")
require("plugins.nvim-lint")
require("plugins.render-markdown")
require("plugins.autopairs")
require("plugins.fterm")
require("plugins.fzf-lua")
require("plugins.nvim-tree")
require("plugins.twilight")
require("plugins.which-key")
require("plugins.conform")
require("plugins.venv-selector")
