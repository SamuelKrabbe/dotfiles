local M = {}
M.current_theme = "catppuccin-mocha"

function M.enable_transparency()
    local groups = { "Normal" }
    for _, group in ipairs(groups) do
        vim.api.nvim_set_hl(0, group, { bg = "none" })
    end
end

function M.get_lualine_theme()
    if M.current_theme:find("catppuccin") then
        return "catppuccin"
    elseif M.current_theme:find("tokyonight") then
        return "tokyonight"
    else
        return "auto"
    end
end

function M.set_theme(name)
    vim.cmd.colorscheme(name)
    M.enable_transparency()
    M.current_theme = name
    print("Theme set to " .. name)
    local ok, lualine = pcall(require, "lualine")
    if ok then
        lualine.setup({ options = { theme = M.get_lualine_theme() } })
    end
end

return M
