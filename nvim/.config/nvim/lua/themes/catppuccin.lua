return {
	"catppuccin/nvim",
	enabled = false,
	lazy = false,
	name = "catppuccin",
	priority = 1000,
	opts = { transparent_background = true, flavour = "mocha" },
	config = function(_, opts)
		require("catppuccin").setup(opts)
		vim.cmd("colorscheme catppuccin")
	end,
}
