local theme = require("core.theme")

-- Create a dedicated augroup for all user autocommands
local augroup = vim.api.nvim_create_augroup("UserConfig", {})

-- ======================================================================
-- General Editor Behavior
-- ======================================================================

-- Highlight text briefly after yanking it
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Restore last cursor position when reopening a file
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- ======================================================================
-- Filetype Settings
-- ======================================================================

-- Use 4 spaces for Lua and Python
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "lua", "python" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
  end,
})

-- Use 2 spaces for web development files
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "javascript", "typescript", "json", "html", "css" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})

-- ======================================================================
-- Terminal Behavior
-- ======================================================================

-- Automatically close terminal buffer when the process exits successfully
vim.api.nvim_create_autocmd("TermClose", {
  group = augroup,
  callback = function()
    if vim.v.event.status == 0 then
      vim.api.nvim_buf_delete(0, {})
    end
  end,
})

-- Disable UI elements inside terminal buffers for a cleaner look
vim.api.nvim_create_autocmd("TermOpen", {
  group = augroup,
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
  end,
})

-- ======================================================================
-- Window Management
-- ======================================================================

-- Equalize split sizes when the Neovim window is resized
vim.api.nvim_create_autocmd("VimResized", {
  group = augroup,
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- ======================================================================
-- File Management
-- ======================================================================

-- Automatically create missing directories when saving a file
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup,
  callback = function()
    local dir = vim.fn.expand("<afile>:p:h")
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end
  end,
})

-- ======================================================================
-- Theme Management
-- ======================================================================

-- Command to toggle between predefined themes
vim.api.nvim_create_user_command("ToggleTheme", function()
  if (vim.g.colors_name or ""):find("tokyonight") then
    theme.set_theme("catppuccin")
  else
    theme.set_theme("tokyonight")
  end
end, {})

-- Apply current theme on startup
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    theme.set_theme(theme.current_theme)
  end,
})

-- ======================================================================
-- Quickfix Handling
-- ======================================================================

-- Automatically open the quickfix window after running :make or :grep if results exist
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  pattern = { "make", "grep", "grepadd" },
  callback = function()
    if not vim.tbl_isempty(vim.fn.getqflist()) then
      vim.cmd("copen")
      vim.cmd("wincmd p") -- return to previous window
    end
  end,
})

-- Close the quickfix window automatically if it's empty
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  callback = function()
    if vim.tbl_isempty(vim.fn.getqflist()) then
      pcall(vim.cmd, "cclose")
    end
  end,
})

-- Auto-close quickfix window when leaving it
vim.api.nvim_create_autocmd("BufLeave", {
  pattern = "quickfix",
  callback = function()
    vim.cmd("cclose")
  end,
})
