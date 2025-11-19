return {
    "hrsh7th/cmp-nvim-lsp",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "hrsh7th/nvim-cmp",
        { "antosha417/nvim-lsp-file-operations", config = true },
        { "folke/lazydev.nvim", opts = {} },
    },
    config = function()
        local cmp_nvim_lsp = require("cmp_nvim_lsp")

        local capabilities = cmp_nvim_lsp.default_capabilities()

        vim.lsp.config("*", {
            capabilities = capabilities,
        })

        -- Diagnostics setup
        local icons = { Error = "", Warn = "", Hint = "", Info = "" }
        vim.diagnostic.config({
            underline = true,
            update_in_insert = false,
            virtual_text = { spacing = 4, source = "if_many", prefix = "●" },
            severity_sort = true,
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = icons.Error,
                    [vim.diagnostic.severity.WARN] = icons.Warn,
                    [vim.diagnostic.severity.HINT] = icons.Hint,
                    [vim.diagnostic.severity.INFO] = icons.Info,
                },
            },
        })


        -- Autoformat on save
        vim.api.nvim_create_autocmd("BufWritePre", {
            callback = function()
                vim.lsp.buf.format({
                    async = false,
                    timeout_ms = 3000,
                    filter = function(client)
                        -- Prefer null-ls/none-ls
                        if client.name == "null-ls" then
                            return true
                        end

                        -- Otherwise allow any LSP that supports formatting
                        return client.supports_method("textDocument/formatting")
                    end,
                })
            end,
        })
    end,
}
