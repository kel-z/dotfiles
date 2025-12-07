return {
	"lewis6991/gitsigns.nvim",
	event = "VeryLazy",
	opts = {
		on_attach = function(bufnr)
			local gitsigns = require("gitsigns")

			-- Navigation
			vim.keymap.set("n", "]c", function()
				if vim.wo.diff then
					vim.cmd.normal({ "]c", bang = true })
				else
					gitsigns.nav_hunk("next")
				end
			end, { buffer = bufnr, desc = "Next hunk" })

			vim.keymap.set("n", "[c", function()
				if vim.wo.diff then
					vim.cmd.normal({ "[c", bang = true })
				else
					gitsigns.nav_hunk("prev")
				end
			end, { buffer = bufnr, desc = "Previous hunk" })

			-- Actions
			vim.keymap.set("n", "<leader>hs", gitsigns.stage_hunk, { buffer = bufnr, desc = "Stage hunk" })
			vim.keymap.set("n", "<leader>hr", gitsigns.reset_hunk, { buffer = bufnr, desc = "Reset hunk" })

			vim.keymap.set("v", "<leader>hs", function()
				gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end, { buffer = bufnr, desc = "Stage selected hunk" })

			vim.keymap.set("v", "<leader>hr", function()
				gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end, { buffer = bufnr, desc = "Reset selected hunk" })

			vim.keymap.set("n", "<leader>hS", gitsigns.stage_buffer, { buffer = bufnr, desc = "Stage buffer" })
			vim.keymap.set("n", "<leader>hR", gitsigns.reset_buffer, { buffer = bufnr, desc = "Reset buffer" })
			vim.keymap.set("n", "<leader>hp", gitsigns.preview_hunk, { buffer = bufnr, desc = "Preview hunk" })
			vim.keymap.set(
				"n",
				"<leader>hi",
				gitsigns.preview_hunk_inline,
				{ buffer = bufnr, desc = "Preview hunk inline" }
			)

			vim.keymap.set("n", "<leader>hb", function()
				gitsigns.blame_line({ full = true })
			end, { buffer = bufnr, desc = "Blame line" })

			vim.keymap.set("n", "<leader>hd", gitsigns.diffthis, { buffer = bufnr, desc = "Diff this" })

			vim.keymap.set("n", "<leader>hD", function()
				gitsigns.diffthis("~")
			end, { buffer = bufnr, desc = "Diff this against ~" })

			vim.keymap.set("n", "<leader>hQ", function()
				gitsigns.setqflist("all")
			end, { buffer = bufnr, desc = "Set qflist for all hunks" })
			vim.keymap.set(
				"n",
				"<leader>hq",
				gitsigns.setqflist,
				{ buffer = bufnr, desc = "Set qflist for buffer hunks" }
			)

			-- Toggles
			vim.keymap.set(
				"n",
				"<leader>tb",
				gitsigns.toggle_current_line_blame,
				{ buffer = bufnr, desc = "Toggle current line blame" }
			)
			vim.keymap.set("n", "<leader>tw", gitsigns.toggle_word_diff, { buffer = bufnr, desc = "Toggle word diff" })

			-- Text object
			vim.keymap.set({ "o", "x" }, "ih", gitsigns.select_hunk, { buffer = bufnr, desc = "Select hunk" })
		end,
	},
}
