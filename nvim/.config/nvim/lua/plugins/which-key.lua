return {
	-- Useful plugin to show you pending keybinds.
	"folke/which-key.nvim",
	event = "VimEnter", -- Sets the loading event to 'VimEnter'
	opts = {
		-- delay between pressing a key and opening which-key (milliseconds)
		-- this setting is independent of vim.o.timeoutlen
		delay = 0,
		icons = {
			-- set icon mappings to true if you have a Nerd Font
			mappings = vim.g.have_nerd_font,
			-- If you are using a Nerd Font: set icons.keys to an empty table which will use the
			-- default which-key.nvim defined Nerd Font icons, otherwise define a string table
			keys = vim.g.have_nerd_font and {} or {
				Up = "<Up> ",
				Down = "<Down> ",
				Left = "<Left> ",
				Right = "<Right> ",
				C = "<C-…> ",
				M = "<M-…> ",
				D = "<D-…> ",
				S = "<S-…> ",
				CR = "<CR> ",
				Esc = "<Esc> ",
				ScrollWheelDown = "<ScrollWheelDown> ",
				ScrollWheelUp = "<ScrollWheelUp> ",
				NL = "<NL> ",
				BS = "<BS> ",
				Space = "<Space> ",
				Tab = "<Tab> ",
				F1 = "<F1>",
				F2 = "<F2>",
				F3 = "<F3>",
				F4 = "<F4>",
				F5 = "<F5>",
				F6 = "<F6>",
				F7 = "<F7>",
				F8 = "<F8>",
				F9 = "<F9>",
				F10 = "<F10>",
				F11 = "<F11>",
				F12 = "<F12>",
			},
		},

		-- Document existing key chains
		spec = {
			{ "<leader>s", group = "[S]earch" },
			{ "<leader>sf", desc = "[S]earch [F]iles" },
			{ "<leader>sF", desc = "[S]earch [F]iles (including hidden)" },
			{ "<leader>sg", desc = "[S]earch by [G]rep" },
			{ "<leader>sw", desc = "[S]earch current [W]ord" },
			{ "<leader>s/", desc = "[S]earch [/] in Open Files" },
			{ "<leader>ss", desc = "[S]earch [S]elect Telescope" },
			{ "<leader>sh", desc = "[S]earch [H]elp" },
			{ "<leader>sk", desc = "[S]earch [K]eymaps" },
			{ "<leader>sb", desc = "[S]earch [B]uffers" },
			{ "<leader>sd", desc = "[S]earch [D]iagnostics" },
			{ "<leader>sr", desc = "[S]earch [R]esume" },
			{ "<leader>s.", desc = '[S]earch Recent Files ("." for repeat)' },
			{ "<leader>sn", desc = "[S]earch [N]eovim files" },
			{ "<leader>/", desc = "[/] Fuzzily search in current buffer" },
			{ "<leader><leader>", desc = "[ ] Find existing buffers" },

			{ "<leader>g", group = "[G]it" },
			{ "<leader>gl", group = "[G]it [L]ist" },
			{ "<leader>glc", desc = "[G]it [L]ist [C]ommits" },
			{ "<leader>gls", desc = "[G]it [L]ist [S]tash" },

			{ "<leader>r", group = "[R]eplace/Substitute" },
			{ "<leader>rr", desc = "[R]ange substitute word" },

			{ "<leader>t", group = "[T]oggle" },
			{ "<leader>td", desc = "[T]oggle [D]iagnostics" },
			{ "<leader>tm", desc = "[T]oggle [M]arkview" },
			{ "<leader>th", desc = "[T]oggle [H]ints (LSP)" },
			{ "<leader>tb", desc = "[T]oggle [B]lame" },
			{ "<leader>tw", desc = "[T]oggle [W]ord diff" },

			{ "<leader>cf", desc = "[C]opy [F]ile path" },
			{ "<leader>dp", desc = "[D]elete and [P]aste" },

			{ "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
			{ "<leader>hs", desc = "[H]unk [S]tage", mode = { "n", "v" } },
			{ "<leader>hr", desc = "[H]unk [R]eset", mode = { "n", "v" } },
			{ "<leader>hS", desc = "[H]unk [S]tage buffer" },
			{ "<leader>hR", desc = "[H]unk [R]eset buffer" },
			{ "<leader>hp", desc = "[H]unk [P]review" },
			{ "<leader>hi", desc = "[H]unk preview [I]nline" },
			{ "<leader>hb", desc = "[H]unk [B]lame" },
			{ "<leader>hd", desc = "[H]unk [D]iff" },
			{ "<leader>hD", desc = "[H]unk [D]iff against ~" },
			{ "<leader>hq", desc = "[H]unk [Q]uickfix (buffer)" },
			{ "<leader>hQ", desc = "[H]unk [Q]uickfix (all)" },

			{ "<leader>y", desc = "[Y]azi file manager", mode = { "n", "v" } },
			{ "<leader>cw", desc = "[C]wd [W]orking directory" },

			{ "<leader>a", desc = "[A]dd to Harpoon" },
			{ "<leader>e", desc = "[E]dit Harpoon menu" },
			{ "<leader>1", desc = "[1] Harpoon select" },
			{ "<leader>2", desc = "[2] Harpoon select" },
			{ "<leader>3", desc = "[3] Harpoon select" },
			{ "<leader>4", desc = "[4] Harpoon select" },
			{ "<leader>p", desc = "[P]revious Harpoon buffer" },
			{ "<leader>n", desc = "[N]ext Harpoon buffer" },

			{ "<leader>jq", desc = "[J][Q] format JSON" },
			{ "<leader>o", group = "[O]rganize" },
			{ "<leader>co", desc = "[C]ode [O]rganize imports" },

			{ "<C-h>", desc = "Move focus to the left window" },
			{ "<C-j>", desc = "Move focus to the lower window" },
			{ "<C-k>", desc = "Move focus to the upper window" },
			{ "<C-l>", desc = "Move focus to the right window" },

			{ "<C-n>", desc = "Next quickfix item" },
			{ "<C-p>", desc = "Previous quickfix item" },

			{ "gy", desc = "Cop[y] to system clipboard", mode = { "n", "x" } },
			{ "gp", desc = "[P]aste from system clipboard", mode = { "n", "x" } },

			{ "[c", desc = "Previous hunk" },
			{ "]c", desc = "Next hunk" },

			{ "s", desc = "[S]ubstitute operator", mode = { "n", "x" } },
			{ "ss", desc = "[S]ubstitute line" },
			{ "S", desc = "[S]ubstitute to end of line" },

			{ "grd", desc = "[G]oto [D]efinition" },
			{ "grD", desc = "[G]oto [D]eclaration" },
			{ "gri", desc = "[G]oto [I]mplementation" },
			{ "grr", desc = "[G]oto [R]eferences" },
			{ "grt", desc = "[G]oto [T]ype definition" },
			{ "gO", desc = "Open [O]ocument symbols" },
			{ "gW", desc = "Open [W]orkspace symbols" },
			{ "gra", desc = "[G]oto Code [A]ction", mode = { "n", "x" } },
			{ "grn", desc = "[G][R]ename symbol" },
		},
	},
}

