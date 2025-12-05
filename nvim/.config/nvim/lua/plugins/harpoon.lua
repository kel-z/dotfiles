return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
	config = function()
		local harpoon = require("harpoon")
		harpoon:setup()

		-- Add to quick menu
		vim.keymap.set("n", "<leader>a", function()
			harpoon:list():add()
		end, { desc = "Add to quick menu" })

		-- Toggle quick menu
		vim.keymap.set("n", "<leader>e", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end, { desc = "Toggle quick menu" })

		-- Quick file selection using leader keys
		vim.keymap.set("n", "<leader>1", function()
			harpoon:list():select(1)
		end, { desc = "Select quick menu file 1" })
		vim.keymap.set("n", "<leader>2", function()
			harpoon:list():select(2)
		end, { desc = "Select quick menu file 2" })
		vim.keymap.set("n", "<leader>3", function()
			harpoon:list():select(3)
		end, { desc = "Select quick menu file 3" })
		vim.keymap.set("n", "<leader>4", function()
			harpoon:list():select(4)
		end, { desc = "Select quick menu file 4" })

		-- Toggle previous & next buffers stored within Harpoon list
		vim.keymap.set("n", "<leader>p", function()
			harpoon:list():prev()
		end, { desc = "Previous Harpoon buffer" })
		vim.keymap.set("n", "<leader>n", function()
			harpoon:list():next()
		end, { desc = "Next Harpoon buffer" })
	end,
}
