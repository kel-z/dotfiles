vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.have_nerd_font = true

vim.o.number = true
vim.o.relativenumber = true

vim.o.mouse = "a"

vim.o.showmode = false

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.signcolumn = "yes"

vim.o.updatetime = 250

vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.o.inccommand = "split"

vim.o.cursorline = true

vim.o.scrolloff = 10

vim.o.confirm = true

-- Tab settings
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR><ESC>")

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- jq keybindings for JSON processing
vim.keymap.set("n", "<leader>jq", ":%!jq .<CR>", { desc = "Format entire buffer with jq" })

-- Quickfix navigation
vim.keymap.set("n", "<C-n>", "<cmd>cnext<CR>", { desc = "Next quickfix item" })
vim.keymap.set("n", "<C-p>", "<cmd>cprev<CR>", { desc = "Previous quickfix item" })

-- Copy/paste with system clipboard
vim.keymap.set({ "n", "x" }, "gy", '"+y', { desc = "Copy to system clipboard" })
vim.keymap.set("n", "gp", '"+p', { desc = "Paste from system clipboard" })
-- - Paste in Visual with `P` to not copy selected text (`:h v_P`)
vim.keymap.set("x", "gp", '"+P', { desc = "Paste from system clipboard" })

-- Copy current file path to clipboard
vim.keymap.set("n", "<leader>cf", function()
	local file_path = vim.fn.expand("%:p")
	vim.fn.setreg("+", file_path)
	vim.notify("Copied: " .. file_path)
end, { desc = "Copy [F]ile path" })

vim.keymap.set("x", "<leader>dp", '"_dP', { desc = "Delete and paste without overwriting register" })
vim.keymap.set("n", "<leader>dp", '"_dp', { desc = "Delete and paste without overwriting register" })

-- Markview toggle
vim.keymap.set("n", "<leader>tm", "<cmd>Markview toggle<CR>", { desc = "[T]oggle [M]arkview" })

-- [[ Basic Autocommands ]]

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- Quickfix list keymaps
vim.api.nvim_create_autocmd("FileType", {
	pattern = "qf",
	desc = "Attach keymaps for quickfix list",
	group = vim.api.nvim_create_augroup("kickstart-quickfix", { clear = true }),
	callback = function()
		vim.keymap.set("n", "dd", function()
			local qf_list = vim.fn.getqflist()
			local current_line_number = vim.fn.line(".")

			if qf_list[current_line_number] then
				table.remove(qf_list, current_line_number)
				vim.fn.setqflist(qf_list, "r")

				local new_line_number = math.min(current_line_number, #qf_list)
				vim.fn.cursor(new_line_number, 1)
			end
		end, {
			buffer = true,
			noremap = true,
			silent = true,
			desc = "Remove quickfix item under cursor",
		})
	end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
require("lazy").setup({
	{ import = "plugins" },
	{ import = "themes" },
}, {
	ui = {
		-- If you are using a Nerd Font: set icons to an empty table which will use the
		-- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
		icons = vim.g.have_nerd_font and {} or {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			require = "🌙",
			source = "📄",
			start = "🚀",
			task = "📌",
			lazy = "💤 ",
		},
	},
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=4 sts=4 sw=4 et
