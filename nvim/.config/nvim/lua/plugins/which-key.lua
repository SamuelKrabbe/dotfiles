return {
    {
        "folke/which-key.nvim",
        event = "VeryLazy",

    -- Allows extending the `spec` table across multiple files
    opts_extend = { "spec" },

    opts = {
      preset = "helix",

      -- Only `spec` should be used; `defaults` is deprecated.
      spec = {
        {
          mode = { "n", "x" },

          { "<leader><tab>", group = "tabs" },
          { "<leader>c",     group = "code" },
          { "<leader>d",     group = "debug" },
          { "<leader>dp",    group = "profiler" },
          { "<leader>f",     group = "file/find" },
          { "<leader>g",     group = "git" },
          { "<leader>gh",    group = "hunks" },
          { "<leader>q",     group = "quit/session" },
          { "<leader>s",     group = "split" },
          { "<leader>u",     group = "ui" },
          { "<leader>x",     group = "diagnostics/quickfix" },

          -- Movement groups
          { "[",  group = "prev" },
          { "]",  group = "next" },
          { "g",  group = "goto" },
          { "gs", group = "surround" },
          { "z",  group = "fold" },

          -- Buffer group (dynamic expansion)
          {
            "<leader>b",
            group = "buffer",
            expand = function()
              return require("which-key.extras").expand.buf()
            end,
          },

          -- Window group (proxy to <C-w>)
          {
            "<leader>w",
            group = "windows",
            proxy = "<c-w>",
            expand = function()
              return require("which-key.extras").expand.win()
            end,
          },

          -- Misc
          { "gx", desc = "Open with system app" },
        },
      },
    },

    -- Direct which-key keymaps
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer keymaps (which-key)",
      },
      {
        "<c-w><space>",
        function()
          require("which-key").show({ keys = "<c-w>", loop = true })
        end,
        desc = "Window hydra mode (which-key)",
      },
    },

    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)

      -- Fallback warning for deprecated `defaults`
      if not vim.tbl_isempty(opts.defaults or {}) then
        LazyVim.warn("which-key: opts.defaults is deprecated. Use opts.spec instead.")
        wk.register(opts.defaults)
      end
    end,
  },
}
