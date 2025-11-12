local conf = require("telescope.config").values
local themes = require("telescope.themes")

-- Helper function to open Harpoon list with Telescope
local function toggle_telescope(harpoon_files)
  local file_paths = {}
  for _, item in ipairs(harpoon_files.items) do
    table.insert(file_paths, item.value)
  end

  local opts = themes.get_ivy({
    prompt_title = "Working List",
  })

  require("telescope.pickers").new(opts, {
    finder = require("telescope.finders").new_table({
      results = file_paths,
    }),
    previewer = conf.file_previewer(opts),
    sorter = conf.generic_sorter(opts),
  }):find()
end

return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },

  opts = {
    menu = {
      width = vim.api.nvim_win_get_width(0) - 4,
    },
    settings = {
      save_on_toggle = true,
    },
  },

  config = function(_, opts)
    local harpoon = require("harpoon")
    harpoon:setup(opts)

    -- ==========================
    -- Harpoon Keymaps
    -- ==========================
    vim.keymap.set("n", "<leader>ha", function()
      harpoon:list():add()
      vim.notify("File added to Harpoon")
    end, { desc = "Add file to Harpoon" })

    vim.keymap.set("n", "<leader>hh", function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = "Harpoon menu" })

    vim.keymap.set("n", "<leader>hf", function()
      toggle_telescope(harpoon:list())
    end, { desc = "Find in Harpoon (Telescope)" })

    vim.keymap.set("n", "<leader>hn", function()
      harpoon:list():next()
    end, { desc = "Next Harpoon file" })

    vim.keymap.set("n", "<leader>hp", function()
      harpoon:list():prev()
    end, { desc = "Previous Harpoon file" })

    vim.keymap.set("n", "<leader>hc", function()
      harpoon:list():clear()
    end, { desc = "Clear Harpoon list" })

    vim.keymap.set("n", "<leader>hr", function()
      harpoon:list():remove()
      vim.notify("File removed from Harpoon")
    end, { desc = "Remove current file from Harpoon" })

    -- Numbers 1–9 to jump to Harpoon slots
    for i = 1, 9 do
      vim.keymap.set("n", "<leader>" .. i, function()
        harpoon:list():select(i)
      end, { desc = "Harpoon to file " .. i })
    end
  end,
}
