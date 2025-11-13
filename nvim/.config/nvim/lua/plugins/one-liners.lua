return {
    { -- This helps with ssh tunneling and copying to clipboard
        "ojroques/vim-oscyank",
    },
    { -- Show historical versions of the file locally
        "mbbill/undotree",
        config = function()
            vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle, { desc = "Toggle undotree" } )
        end
    },
    { -- Show CSS Colors
        "brenoprata10/nvim-highlight-colors",
        config = function()
            require("nvim-highlight-colors").setup({})
        end,
    },
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            local npairs = require("nvim-autopairs")
            npairs.setup({
                check_ts = true, -- enables smarter pairs using treesitter
                fast_wrap = {},
                disable_filetype = { "TelescopePrompt", "vim" },
            })
        end,
    },
    {
        "windwp/nvim-ts-autotag",
        event = "InsertEnter",
        config = true,
    }
}
