local M = {}

local valid_themes = {
  tokyonight = true,
  catppuccin = true,
  kanagawa = true,
  terminal = true,
}

local function configured_theme()
  local candidate = vim.env.NVIM_THEME
  if not candidate or candidate == "" then
    local ok, local_config = pcall(require, "config.theme.local")
    if ok and type(local_config) == "table" then
      candidate = local_config.name
    end
  end

  if valid_themes[candidate] then
    return candidate
  end
  return "tokyonight"
end

function M.name()
  return configured_theme()
end

function M.uses_terminal_palette()
  return M.name() == "terminal"
end

function M.setup_tokyonight()
  if M.name() ~= "tokyonight" and not M.uses_terminal_palette() then
    return
  end

  require("tokyonight").setup({
    style = "night",
    transparent = true,
    styles = {
      comments = { italic = true },
      keywords = { italic = true },
      sidebars = "transparent",
      floats = "transparent",
    },
  })
  vim.cmd.colorscheme("tokyonight")

  if M.uses_terminal_palette() then
    require("config.terminal_theme").setup()
  end
end

function M.setup_catppuccin()
  if M.name() ~= "catppuccin" then
    return
  end

  require("catppuccin").setup({
    flavour = "mocha",
    transparent_background = true,
  })
  vim.cmd.colorscheme("catppuccin")
end

function M.setup_kanagawa()
  if M.name() ~= "kanagawa" then
    return
  end

  require("kanagawa").setup({
    transparent = true,
    theme = "dragon",
  })
  vim.cmd.colorscheme("kanagawa-dragon")
end

function M.lualine_theme()
  if M.uses_terminal_palette() then
    return require("config.terminal_theme").lualine_theme() or "auto"
  end
  return "auto"
end

return M
