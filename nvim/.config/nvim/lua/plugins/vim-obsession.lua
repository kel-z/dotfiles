return {
	"tpope/vim-obsession",
	lazy = false,
	config = function()
		if vim.fn.filereadable("Session.vim") == 1 then
			vim.cmd("source Session.vim")
		elseif vim.env.TMUX then
			vim.cmd("Obsess")
		end
	end,
}
