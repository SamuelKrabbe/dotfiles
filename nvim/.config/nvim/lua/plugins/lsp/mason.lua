return {
    {
        "williamboman/mason-lspconfig.nvim",
        opts = {
            -- list of servers for mason to install
            ensure_installed = {
                "ts_ls",
                "html",
                "cssls",
                "tailwindcss",
                "lua_ls",
                "pyright",
                "eslint",
                "gopls",
            },
        },
        dependencies = {
            {
                "williamboman/mason.nvim",
                cmd = "Mason",
                keys = { { "<leader>M", "<cmd>Mason<cr>", desc = "Mason" } },
                build = ":MasonUpdate", 
                opts = {
                    ui = {
                        icons = {
                            package_installed = "✓",
                            package_pending = "➜",
                            package_uninstalled = "✗",
                        },
                    },
                },
            },
            "neovim/nvim-lspconfig",
        },
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        opts = {
            ensure_installed = {
                "prettier", -- prettier formatter
                "stylua", -- lua formatter
                "black", -- python formatter
                "pylint",
                "eslint_d",
                "gofumpt",
                "golines",
                "delve",
            },
        },
        dependencies = {
            "williamboman/mason.nvim",
        },
    },
}
