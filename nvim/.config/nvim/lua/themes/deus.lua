return {
	"ajmwagar/vim-deus",
	enabled = false,
	lazy = false,
	priority = 1000,
	config = function()
		vim.opt.termguicolors = true
		vim.cmd("colorscheme deus")
	end,
}
