local wk = require("which-key")

wk.setup({
	preset = "modern",
	delay = 200,
	win = {
		border = "rounded",
		padding = { 1, 2 },
		title = true,
		title_pos = "center",
	},
	layout = {
		width = { min = 24, max = 50 },
		spacing = 4,
	},
	sort = { "manual", "group", "alphanum", "mod" },
	icons = {
		mappings = true,
		separator = "➜",
	},
})

vim.api.nvim_set_hl(0, "WhichKeyIcon", { link = "WhichKeyDesc" })

wk.add({
	{ "<leader>b", group = "Buffers", icon = "󰓩 " },
	{ "<leader>bd", desc = "Close current buffer", icon = "󰅖 " },
	{ "<leader>bn", desc = "Create new buffer", icon = "󰈔 " },
	{ "<leader>bo", desc = "Close other buffers", icon = "󰅗 " },
	{ "<leader>bp", desc = "Pin buffer", icon = "󰐃 " },
	{ "<leader>bH", desc = "Move buffer left", icon = "󰁍 " },
	{ "<leader>bL", desc = "Move buffer right", icon = "󰁔 " },

	{ "<leader>c", group = "CSV", icon = "󰈛 " },
	{ "<leader>ch", desc = "Check health", icon = "󰓙 " },
	{ "<leader>cs", group = "CSV alignment", icon = "󰘦 " },
	{ "<leader>csa", desc = "Align CSV columns", icon = "󰘦 " },
	{ "<leader>csA", desc = "Clear CSV alignment", icon = "󰅖 " },

	{ "<leader>C", group = "Config", icon = " " },
	{ "<leader>Ci", desc = "Edit init.lua", icon = " " },
	{ "<leader>Cm", desc = "Edit mappings", icon = " " },
	{ "<leader>Co", desc = "Edit options", icon = " " },
	{ "<leader>Cp", desc = "Open plugins dir", icon = " " },

	{ "<leader>d", group = "Diagnostics", icon = "󰒡 " },
	{ "<leader>dd", desc = "Buffer diagnostics", icon = "󰒡 " },
	{ "<leader>df", desc = "Diagnostic float", icon = "󰌵 " },
	{ "<leader>dl", desc = "Diagnostic loclist", icon = "󰅪 " },
	{ "<leader>dv", desc = "Toggle virtual text", icon = "󰍩 " },

	{ "<leader>F", group = "Find locations", icon = "󰍉 " },
	{ "<leader>Fh", desc = "Find files in home", icon = " " },
	{ "<leader>Fc", desc = "Find files in ~/.config", icon = " " },
	{ "<leader>Fl", desc = "Find files in /etc", icon = " " },
	{ "<leader>Ff", desc = "Find files in parent dir", icon = " " },
	{ "<leader>f", desc = "Find files in cwd", icon = "󰈞 " },

	{ "<leader>h", group = "Git hunks", icon = " " },
	{ "<leader>hb", desc = "Blame line", icon = "󰊢 " },
	{ "<leader>hi", desc = "Preview hunk inline", icon = "󰹹 " },
	{ "<leader>hp", desc = "Preview hunk", icon = "󰍉 " },
	{ "<leader>hr", desc = "Reset hunk", icon = "󰜉 " },
	{ "<leader>hs", desc = "Stage hunk", icon = "󰐗 " },

	{ "<leader>l", group = "Language", icon = "󰘦 " },
	{ "<leader>lf", desc = "Format buffer", icon = "󰉢 " },
	{ "<leader>ll", desc = "Run lint", icon = "󰁨 " },

	{ "<leader>n", group = "Numbers", icon = "󰎠 " },
	{ "<leader>nn", desc = "Toggle relative numbers", icon = "󰎡 " },

	{ "<leader>r", group = "Refactor", icon = "󰑕 " },
	{ "<leader>rn", desc = "Rename symbol", icon = "󰑕 " },

	{ "<leader>s", group = "Spelling", icon = "󰓆 " },
	{ "<leader>ss", desc = "Toggle spell", icon = "󰓆 " },

	{ "<leader>x", group = "Trouble", icon = "󰋼 " },
	{ "<leader>xX", desc = "Buffer diagnostics", icon = "󰒡 " },
	{ "<leader>xl", desc = "Location list", icon = "󰅪 " },
	{ "<leader>xq", desc = "Quickfix list", icon = "󰁨 " },
	{ "<leader>xr", desc = "LSP references", icon = "󰈇 " },
	{ "<leader>xx", desc = "Workspace diagnostics", icon = "󰒡 " },

	{ "<leader>e", desc = "Toggle file tree", icon = "󰙅 " },
	{ "<leader>ec", desc = "Collapse file tree", icon = "󰅀 " },
	{ "<leader>ee", desc = "Focus file tree", icon = "󰙅 " },
	{ "<leader>ef", desc = "Reveal current file", icon = "󰈞 " },
	{ "<leader>er", desc = "Refresh file tree", icon = "󰑓 " },
	{ "<leader>g", desc = "Grep cwd", icon = "󰱼 " },
	{ "<leader>ca", desc = "Code action", icon = "󰌵 " },
	{ "<leader>m", group = "Misc", icon = "󰘦 " },
	{ "<leader>mx", desc = "chmod +x", icon = "󰌾 " },
	{ "<leader>P", desc = "Install plugins", icon = "󰏗 " },
	{ "<leader>R", desc = "Reload current file", icon = "󰑓 " },
	{ "<leader>t", desc = "Open floating terminal", icon = " " },
	{ "<leader>v", desc = "Select Python venv", icon = " " },
	{ "<leader>W", desc = "Toggle word wrap", icon = "󰖶 " },
	{ "<leader>y", desc = "Open Yazi", icon = "󰇥 " },
})
