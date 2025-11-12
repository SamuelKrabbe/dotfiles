return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason.nvim",
      { "mason-org/mason-lspconfig.nvim", config = function() end },
    },

    opts_extend = { "servers.*.keys" },

    --- MAIN OPTIONS -----------------------------------------------------------
    opts = function()
      local icons = LazyVim.config.icons.diagnostics

      return {
        diagnostics = {
          underline = true,
          update_in_insert = false,
          virtual_text = {
            spacing = 4,
            source = "if_many",
            prefix = "●",
          },
          severity_sort = true,
          signs = {
            text = {
              [vim.diagnostic.severity.ERROR] = icons.Error,
              [vim.diagnostic.severity.WARN] = icons.Warn,
              [vim.diagnostic.severity.HINT] = icons.Hint,
              [vim.diagnostic.severity.INFO] = icons.Info,
            },
          },
        },

        inlay_hints = {
          enabled = true,
          exclude = { "vue" },
        },

        codelens = { enabled = false },
        folds = { enabled = true },

        format = {
          formatting_options = nil,
          timeout_ms = nil,
        },

        --------------------------------------------------------------------------
        -- LSP SERVER CONFIGS
        --------------------------------------------------------------------------
        servers = {
          ["*"] = {
            capabilities = {
              workspace = {
                fileOperations = { didRename = true, willRename = true },
              },
            },

            keys = LazyVim.lsp.get_standard_keys(),
          },

          stylua = { enabled = false },

          lua_ls = {
            settings = {
              Lua = {
                workspace = { checkThirdParty = false },
                codeLens = { enable = true },
                completion = { callSnippet = "Replace" },
                doc = { privateName = { "^_" } },
                hint = {
                  enable = true,
                  setType = false,
                  paramType = true,
                  paramName = "Disable",
                  semicolon = "Disable",
                  arrayIndex = "Disable",
                },
              },
            },
          },
        },

        setup = {},
      }
    end,

    --- CONFIG FUNCTION ---------------------------------------------------------
    config = vim.schedule_wrap(function(_, opts)
      LazyVim.format.register(LazyVim.lsp.formatter())

      -- set keymaps for each server
      for server, o in pairs(opts.servers) do
        if type(o) == "table" and o.keys then
          require("lazyvim.plugins.lsp.keymaps").set({ name = server ~= "*" and server or nil }, o.keys)
        end
      end

      -- inlay hints
      if opts.inlay_hints.enabled then
        Snacks.util.lsp.on({ method = "textDocument/inlayHint" }, function(buf)
          if
            vim.api.nvim_buf_is_valid(buf)
            and vim.bo[buf].buftype == ""
            and not vim.tbl_contains(opts.inlay_hints.exclude, vim.bo[buf].filetype)
          then
            vim.lsp.inlay_hint.enable(true, { bufnr = buf })
          end
        end)
      end

      -- folds
      if opts.folds.enabled then
        Snacks.util.lsp.on({ method = "textDocument/foldingRange" }, function()
          if LazyVim.set_default("foldmethod", "expr") then
            LazyVim.set_default("foldexpr", "v:lua.vim.lsp.foldexpr()")
          end
        end)
      end

      -- code lens
      if opts.codelens.enabled then
        Snacks.util.lsp.on({ method = "textDocument/codeLens" }, function(buf)
          vim.lsp.codelens.refresh()
          vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
            buffer = buf,
            callback = vim.lsp.codelens.refresh,
          })
        end)
      end

      -- diagnostics
      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      ---------------------------------------------------------------------------
      -- Mason integration
      ---------------------------------------------------------------------------
      local have_mason = LazyVim.has("mason-lspconfig.nvim")
      local mason_map = have_mason and require("mason-lspconfig.mappings").get_mason_map().lspconfig_to_package or {}
      local mason_all = vim.tbl_keys(mason_map)
      local mason_exclude = {}

      local function configure(server)
        if server == "*" then return false end

        local server_opts = opts.servers[server]
        server_opts = server_opts == true and {} or (not server_opts) and { enabled = false } or server_opts

        if server_opts.enabled == false then
          table.insert(mason_exclude, server)
          return
        end

        local uses_mason = server_opts.mason ~= false and vim.tbl_contains(mason_all, server)
        local setup_fn = opts.setup[server] or opts.setup["*"]

        if setup_fn and setup_fn(server, server_opts) then
          table.insert(mason_exclude, server)
          return
        end

        vim.lsp.config(server, server_opts)
        if not uses_mason then
          vim.lsp.enable(server)
        end

        return uses_mason
      end

      local install = vim.tbl_filter(configure, vim.tbl_keys(opts.servers))

      if have_mason then
        require("mason-lspconfig").setup({
          ensure_installed = vim.list_extend(install, LazyVim.opts("mason-lspconfig.nvim").ensure_installed or {}),
          automatic_enable = { exclude = mason_exclude },
        })
      end
    end),
  },

  -------------------------------------------------------------------------------
  -- Mason core
  -------------------------------------------------------------------------------
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",

    opts_extend = { "ensure_installed" },
    opts = {
      ensure_installed = { "stylua", "shfmt" },
    },

    config = function(_, opts)
      local mason = require("mason")
      local registry = require("mason-registry")

      mason.setup(opts)

      registry:on("package:install:success", function()
        vim.defer_fn(function()
          require("lazy.core.handler.event").trigger({
            event = "FileType",
            buf = vim.api.nvim_get_current_buf(),
          })
        end, 100)
      end)

      registry.refresh(function()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = registry.get_package(tool)
          if not p:is_installed() then p:install() end
        end
      end)
    end,
  },
}
