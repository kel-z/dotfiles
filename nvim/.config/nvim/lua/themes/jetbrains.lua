return {
	"nickkadutskyi/jb.nvim",
	enabled = false,
	lazy = false,
	priority = 1000,
	opts = {},
	config = function()
		require("jb").setup({ transparent = true })
		vim.cmd("colorscheme jb")
	end,
}
