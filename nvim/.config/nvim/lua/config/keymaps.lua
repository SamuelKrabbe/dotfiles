-- ======================================================================
-- Leaders
-- ======================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ======================================================================
-- Search & Movement
-- ======================================================================
vim.keymap.set("n", "<leader>c", ":nohlsearch<CR>", { desc = "Clear search highlights" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next match (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous match (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- ======================================================================
-- Editing & Registers
-- ======================================================================
vim.keymap.set("n", "Y", "y$", { desc = "Yank to end of line" })
vim.keymap.set("x", "<leader>p", '"_dP', { desc = "Paste without yanking" })
vim.keymap.set({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without yanking" })
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines (keep cursor)" })
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
vim.keymap.set("v", "<", "<gv", { desc = "Indent left (reselect)" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right (reselect)" })
vim.keymap.set({ "n", "i", "v" }, "<C-s>", function()
    local mode = vim.api.nvim_get_mode().mode
    if mode == "i" then
        vim.cmd("stopinsert")
    end
    vim.cmd("wa")
    vim.notify("All files saved!", vim.log.levels.INFO)
end, { desc = "Save all files" })

-- ======================================================================
-- Windows & Splits
-- ======================================================================
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

vim.keymap.set("n", "<leader>sv", ":vsplit<CR>", { desc = "Vertical split" })
vim.keymap.set("n", "<leader>sh", ":split<CR>", { desc = "Horizontal split" })

vim.keymap.set("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase height" })
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease height" })
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease width" })
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase width" })

-- ======================================================================
-- Buffers
-- ======================================================================
vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })

-- ======================================================================
-- Files & Paths
-- ======================================================================
vim.keymap.set("n", "<leader>e", ":Explore<CR>", { desc = "Open file explorer" })

vim.keymap.set("n", "<leader>pa", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  print("file:", path)
end, { desc = "Copy file path" })

vim.keymap.set("n", "<leader>rc", ":e $MYVIMRC<CR>", { desc = "Open config" })
vim.keymap.set("n", "<leader>rl", ":so $MYVIMRC<CR>", { desc = "Reload config" })
vim.keymap.set("n", "<leader><leader>", ":source<CR>", { desc = "Source current file" })

-- ======================================================================
-- Plugin Management
-- ======================================================================
vim.keymap.set("n", "<C-l>", ":Lazy sync<CR>", { desc = "Sync plugins" })

-- ======================================================================
-- Theme Management
-- ======================================================================
vim.keymap.set("n", "<leader>T", ":ToggleTheme<CR>", { desc = "Toggle theme" })

-- ======================================================================
-- Built-in Terminal
-- ======================================================================
local terminal = require("config.builtin-terminal")
vim.keymap.set("n", "<leader>t", terminal.FloatingTerminal, {
  noremap = true,
  silent = true,
  desc = "Toggle floating terminal",
})

vim.keymap.set("t", "<Esc>", function()
  local st = terminal.terminal_state
  if st.is_open then
    vim.api.nvim_win_close(st.win, false)
    st.is_open = false
  end
end, { noremap = true, silent = true, desc = "Close floating terminal" })

