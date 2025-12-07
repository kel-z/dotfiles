return {
	"tpope/vim-fugitive",
	event = "VeryLazy",
	keys = {
		{ "<leader>gs", "<cmd>Git<cr>", desc = "Git status" },
		{ "<leader>gc", "<cmd>Git commit<cr>", desc = "Git commit" },
		{ "<leader>gp", "<cmd>Git push<cr>", desc = "Git push" },
		{ "<leader>gP", "<cmd>Git pull<cr>", desc = "Git pull" },
		{ "<leader>gb", "<cmd>Git blame<cr>", desc = "Git blame" },
		{ "<leader>gd", "<cmd>Gvdiffsplit<cr>", desc = "Git diff" },
		{ "<leader>gD", "<cmd>Gvdiffsplit!<cr>", desc = "Git 3-way diff" },
		{ "<leader>gw", "<cmd>Gwrite<cr>", desc = "Git write" },
		{ "<leader>gh", "<cmd>diffget //2 | diffupdate<cr>", desc = "Git accept target" },
		{ "<leader>gl", "<cmd>diffget //3 | diffupdate<cr>", desc = "Git accept merge" },
	},
}
