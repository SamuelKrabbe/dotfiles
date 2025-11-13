return {
	{ -- This helps with ssh tunneling and copying to clipboard
		"ojroques/vim-oscyank",
	},
	{ -- Show historical versions of the file locally
		"mbbill/undotree",
        config = function() 
            vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)
        end
	},
	{ -- Show CSS Colors
		"brenoprata10/nvim-highlight-colors",
		config = function()
			require("nvim-highlight-colors").setup({})
		end,
	},
}
