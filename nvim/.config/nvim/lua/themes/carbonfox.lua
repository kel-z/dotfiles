return {
	"EdenEast/nightfox.nvim",
	enabled = true,
	lazy = false,
	priority = 1000,
	opts = { transparent = true },
	config = function(_, opts)
		require("nightfox").setup(opts)
		vim.cmd("colorscheme carbonfox")
	end,
}
