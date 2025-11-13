return {
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts_extend = { "spec" },

        opts = {
            preset = "helix",

            spec = {
                { mode = { "n", "x" } },

                -- Top-level groups
                { "<leader><tab>", group = "tabs" },
                { "<leader>b",     group = "buffers" },
                { "<leader>c",     group = "code" },
                { "<leader>d",     group = "debug" },
                { "<leader>f",     group = "file/find" },
                { "<leader>g",     group = "git" },
                { "<leader>q",     group = "session" },
                { "<leader>s",     group = "split" },
                { "<leader>u",     group = "ui" },
                { "<leader>x",     group = "diagnostics" },

                -- Subgroups
                { "<leader>gh",    group = "git hunk" },
                { "<leader>dp",    group = "profiler" },

                -- Motions / Operators
                { "[",  group = "previous" },
                { "]",  group = "next" },
                { "g",  group = "goto" },
                { "z",  group = "fold" },
                { "gs", group = "surround" },

                -- Buffers: dynamic expansion
                {
                    "<leader>b",
                    expand = function()
                        return require("which-key.extras").expand.buf()
                    end,
                },

                -- Windows: hydra-like mode
                {
                    "<leader>w",
                    group = "window",
                    proxy = "<c-w>",
                    expand = function()
                        return require("which-key.extras").expand.win()
                    end,
                },

                -- Miscellaneous
                { "gx", desc = "Open with system app" },
            },
        },

        keys = {
            {
                "<leader>?",
                function()
                    require("which-key").show({ global = false })
                end,
                desc = "Show buffer keymaps",
            },
            {
                "<c-w><space>",
                function()
                    require("which-key").show({ keys = "<c-w>", loop = true })
                end,
                desc = "Window hydra (which-key)",
            },
        },

        config = function(_, opts)
            local wk = require("which-key")
            wk.setup(opts)

            if not vim.tbl_isempty(opts.defaults or {}) then
                vim.notify(
                    "which-key: `opts.defaults` is deprecated. Use `opts.spec` instead.",
                    vim.log.levels.WARN
                )
                wk.register(opts.defaults)
            end
        end,
    },
}
