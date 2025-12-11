return {
	"gbprod/substitute.nvim",
	event = "VeryLazy",
	opts = {},
	config = function()
		require("substitute").setup()
		vim.keymap.set("n", "<leader>r", require("substitute.range").operator, { desc = "Range substitute operator" })
		vim.keymap.set("x", "<leader>r", require("substitute.range").visual, { desc = "Range substitute visual" })
		vim.keymap.set("n", "<leader>rr", require("substitute.range").word, { desc = "Range substitute word" })
		vim.keymap.set("n", "s", require("substitute").operator, { noremap = true })
		vim.keymap.set("n", "ss", require("substitute").line, { noremap = true })
		vim.keymap.set("n", "S", require("substitute").eol, { noremap = true })
		vim.keymap.set("x", "s", require("substitute").visual, { noremap = true })
	end,
}
