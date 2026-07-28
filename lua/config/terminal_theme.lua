local M = {}

local uv = vim.uv or vim.loop
local source_name = "kitty-theme.conf"

local function source_path()
  local override = vim.g.terminal_theme_file or vim.env.NVIM_TERMINAL_THEME_FILE
  if override and override ~= "" then
    return vim.fn.expand(override)
  end

  local state_home = vim.env.XDG_STATE_HOME
  if not state_home or state_home == "" then
    state_home = vim.fn.expand("~/.local/state")
  else
    state_home = vim.fn.expand(state_home)
  end

  return state_home .. "/quickshell/user/generated/terminal/kitty-theme.conf"
end

local function read_palette()
  local path = source_path()
  if vim.fn.filereadable(path) ~= 1 then
    return nil
  end

  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then
    return nil
  end

  local palette = { colors = {} }
  for _, line in ipairs(lines) do
    local key, value = line:match("^%s*(%S+)%s+(#%x%x%x%x%x%x)")
    if key and value then
      if key == "background" or key == "foreground"
          or key == "selection_background" or key == "selection_foreground" then
        palette[key] = value
      else
        local index = key:match("^color(%d+)$")
        if index then
          palette.colors[tonumber(index)] = value
        end
      end
    end
  end

  if not palette.background or not palette.foreground then
    return nil
  end

  for index = 0, 15 do
    if not palette.colors[index] then
      return nil
    end
  end

  return palette
end

local function colors_from(palette)
  return {
    bg = palette.background,
    fg = palette.foreground,
    black = palette.colors[0],
    red = palette.colors[1],
    green = palette.colors[2],
    yellow = palette.colors[3],
    blue = palette.colors[4],
    magenta = palette.colors[5],
    cyan = palette.colors[6],
    white = palette.colors[7],
    bright_black = palette.colors[8],
    bright_red = palette.colors[9],
    bright_green = palette.colors[10],
    bright_yellow = palette.colors[11],
    bright_blue = palette.colors[12],
    bright_magenta = palette.colors[13],
    bright_cyan = palette.colors[14],
    bright_white = palette.colors[15],
    selection_bg = palette.selection_background or palette.colors[5],
    selection_fg = palette.selection_foreground or palette.background,
    primary = palette.colors[255] or palette.colors[14],
    primary_container = palette.colors[254] or palette.background,
    secondary = palette.colors[253] or palette.colors[13],
    secondary_container = palette.colors[252] or palette.background,
    tertiary = palette.colors[251] or palette.colors[11],
    tertiary_container = palette.colors[250] or palette.background,
    error = palette.colors[249] or palette.colors[9],
    error_container = palette.colors[248] or palette.background,
  }
end

local function highlight(fg, bg, attributes)
  local result = vim.tbl_extend("force", {}, attributes or {})
  if fg then
    result.fg = fg
  end
  if bg then
    result.bg = bg
  end
  return result
end

local function lualine_theme_from(palette)
  local c = colors_from(palette)
  local function mode_section(fg, bg)
    return highlight(fg, bg, { bold = true })
  end

  return {
    normal = {
      a = mode_section(c.primary, c.primary_container),
      b = highlight(c.fg, c.bg),
      c = highlight(c.fg, c.bg),
    },
    insert = {
      a = mode_section(c.tertiary, c.tertiary_container),
      b = highlight(c.fg, c.bg),
      c = highlight(c.fg, c.bg),
    },
    visual = {
      a = mode_section(c.secondary, c.secondary_container),
      b = highlight(c.fg, c.bg),
      c = highlight(c.fg, c.bg),
    },
    replace = {
      a = mode_section(c.error, c.error_container),
      b = highlight(c.fg, c.bg),
      c = highlight(c.fg, c.bg),
    },
    command = {
      a = mode_section(c.secondary, c.secondary_container),
      b = highlight(c.fg, c.bg),
      c = highlight(c.fg, c.bg),
    },
    terminal = {
      a = mode_section(c.primary, c.primary_container),
      b = highlight(c.fg, c.bg),
      c = highlight(c.fg, c.bg),
    },
    inactive = {
      a = highlight(c.bright_black, c.bg),
      b = highlight(c.bright_black, c.bg),
      c = highlight(c.bright_black, c.bg),
    },
  }
end

local function refresh_lualine_transitions()
  local ok, transition_groups = pcall(
    vim.fn.getcompletion,
    "lualine_transitional_",
    "highlight"
  )
  if not ok then
    return
  end

  for _, group in ipairs(transition_groups) do
    local left_name, right_name = group:match(
      "^lualine_transitional_(.+)_to_(.+)$"
    )
    if left_name and right_name then
      local left = vim.api.nvim_get_hl(0, { name = left_name, link = false })
      local right = vim.api.nvim_get_hl(0, { name = right_name, link = false })
      if left.bg and right.bg then
        vim.api.nvim_set_hl(0, group, {
          fg = left.bg,
          bg = right.bg,
          nocombine = true,
        })
      end
    end
  end
end

local function set_highlights(palette)
  local c = colors_from(palette)
  local groups = {
    -- Keep the editor surface transparent so Kitty and Hyprland provide the
    -- background, while UI surfaces use the same generated background color.
    Normal = highlight(c.fg, "NONE"),
    NormalNC = highlight(c.fg, "NONE"),
    NormalFloat = highlight(c.fg, "NONE"),
    SignColumn = highlight(c.fg, "NONE"),
    FoldColumn = highlight(c.bright_black, "NONE"),
    EndOfBuffer = highlight(c.black, "NONE"),
    MsgArea = highlight(c.fg, "NONE"),
    ModeMsg = highlight(c.fg, "NONE", { bold = true }),
    MoreMsg = highlight(c.green, "NONE"),
    Question = highlight(c.cyan, "NONE"),
    Directory = highlight(c.cyan, "NONE", { bold = true }),

    LineNr = highlight(c.white, "NONE"),
    LineNrAbove = highlight(c.white, "NONE"),
    LineNrBelow = highlight(c.white, "NONE"),
    CursorLine = highlight(nil, c.bg),
    CursorLineNr = highlight(c.bright_yellow, c.bg, { bold = true }),
    CursorLineSign = highlight(c.bright_yellow, c.bg),
    ColorColumn = highlight(nil, c.bg),
    VertSplit = highlight(c.bright_black, "NONE"),
    WinSeparator = highlight(c.bright_black, "NONE"),

    StatusLine = highlight(c.fg, c.bg),
    StatusLineNC = highlight(c.bright_black, c.bg),
    TabLine = highlight(c.bright_black, c.bg),
    TabLineFill = highlight(c.bright_black, c.bg),
    TabLineSel = highlight(c.fg, c.blue, { bold = true }),

    FloatBorder = highlight(c.cyan, "NONE"),
    Pmenu = highlight(c.fg, c.bg),
    PmenuSel = highlight(c.selection_fg, c.selection_bg, { bold = true }),
    PmenuSbar = highlight(nil, c.bright_black),
    PmenuThumb = highlight(nil, c.fg),
    WildMenu = highlight(c.selection_fg, c.selection_bg, { bold = true }),

    Search = highlight(c.selection_fg, c.selection_bg),
    IncSearch = highlight(c.selection_fg, c.magenta, { bold = true }),
    CurSearch = highlight(c.selection_fg, c.magenta, { bold = true }),
    Visual = highlight(c.selection_fg, c.selection_bg),
    MatchParen = highlight(c.bright_yellow, c.bg, { bold = true }),

    SpecialKey = highlight(c.bright_blue, "NONE"),
    NonText = highlight(c.bright_black, "NONE"),
    Conceal = highlight(c.bright_black, "NONE"),
    Folded = highlight(c.bright_blue, c.bg),
    Title = highlight(c.blue, "NONE", { bold = true }),
    WarningMsg = highlight(c.bright_yellow, "NONE", { bold = true }),
    ErrorMsg = highlight(c.bright_red, "NONE", { bold = true }),

    -- Vim syntax groups.
    Comment = highlight(c.white, nil, { italic = true }),
    Constant = highlight(c.magenta, nil),
    String = highlight(c.green, nil),
    Character = highlight(c.green, nil),
    Number = highlight(c.yellow, nil),
    Boolean = highlight(c.bright_yellow, nil, { bold = true }),
    Float = highlight(c.yellow, nil),
    Identifier = highlight(c.blue, nil),
    Function = highlight(c.cyan, nil, { bold = true }),
    Statement = highlight(c.magenta, nil),
    Conditional = highlight(c.magenta, nil),
    Repeat = highlight(c.magenta, nil),
    Label = highlight(c.magenta, nil),
    Operator = highlight(c.bright_magenta, nil),
    Keyword = highlight(c.magenta, nil),
    Exception = highlight(c.bright_red, nil),
    PreProc = highlight(c.red, nil),
    Include = highlight(c.red, nil),
    Define = highlight(c.red, nil),
    Macro = highlight(c.red, nil),
    PreCondit = highlight(c.red, nil),
    Type = highlight(c.cyan, nil),
    StorageClass = highlight(c.cyan, nil),
    Structure = highlight(c.cyan, nil),
    Typedef = highlight(c.cyan, nil),
    Special = highlight(c.bright_cyan, nil),
    SpecialChar = highlight(c.bright_cyan, nil),
    Tag = highlight(c.blue, nil),
    Delimiter = highlight(c.fg, nil),
    Debug = highlight(c.bright_red, nil),
    Underlined = highlight(c.cyan, nil, { underline = true }),
    Error = highlight(c.bright_red, nil, { bold = true }),
    Todo = highlight(c.bright_yellow, c.bg, { bold = true }),

    -- Tree-sitter groups. Links keep the semantic mapping small and stable.
    ["@comment"] = { link = "Comment" },
    ["@constant"] = { link = "Constant" },
    ["@constant.builtin"] = { link = "Constant" },
    ["@string"] = { link = "String" },
    ["@string.escape"] = { link = "SpecialChar" },
    ["@character"] = { link = "Character" },
    ["@number"] = { link = "Number" },
    ["@boolean"] = { link = "Boolean" },
    ["@float"] = { link = "Float" },
    ["@variable"] = { link = "Identifier" },
    ["@variable.builtin"] = { link = "Special" },
    ["@parameter"] = { link = "Identifier" },
    ["@property"] = { link = "Identifier" },
    ["@field"] = { link = "Identifier" },
    ["@function"] = { link = "Function" },
    ["@function.call"] = { link = "Function" },
    ["@function.builtin"] = { link = "Special" },
    ["@method"] = { link = "Function" },
    ["@method.call"] = { link = "Function" },
    ["@constructor"] = { link = "Type" },
    ["@keyword"] = { link = "Keyword" },
    ["@keyword.function"] = { link = "Keyword" },
    ["@keyword.return"] = { link = "Keyword" },
    ["@operator"] = { link = "Operator" },
    ["@type"] = { link = "Type" },
    ["@type.builtin"] = { link = "Type" },
    ["@module"] = { link = "Identifier" },
    ["@namespace"] = { link = "Identifier" },
    ["@tag"] = { link = "Tag" },
    ["@tag.attribute"] = { link = "Identifier" },
    ["@tag.delimiter"] = { link = "Delimiter" },
    ["@punctuation.delimiter"] = { link = "Delimiter" },
    ["@punctuation.bracket"] = { link = "Delimiter" },

    -- Diagnostics, LSP references, Git signs and common plugin surfaces.
    DiagnosticError = highlight(c.bright_red, nil),
    DiagnosticWarn = highlight(c.bright_yellow, nil),
    DiagnosticInfo = highlight(c.bright_cyan, nil),
    DiagnosticHint = highlight(c.bright_green, nil),
    DiagnosticOk = highlight(c.bright_green, nil),
    DiagnosticVirtualTextError = highlight(c.bright_red, c.bg),
    DiagnosticVirtualTextWarn = highlight(c.bright_yellow, c.bg),
    DiagnosticVirtualTextInfo = highlight(c.bright_cyan, c.bg),
    DiagnosticVirtualTextHint = highlight(c.bright_green, c.bg),
    LspReferenceText = highlight(nil, c.bg),
    LspReferenceRead = highlight(nil, c.bg),
    LspReferenceWrite = highlight(nil, c.bg),
    GitSignsAdd = highlight(c.green, nil),
    GitSignsChange = highlight(c.yellow, nil),
    GitSignsDelete = highlight(c.red, nil),
    GitSignsCurrentLineBlame = highlight(c.bright_white, c.bg, { italic = true }),
    DiffAdd = highlight(c.green, c.bg),
    DiffChange = highlight(c.yellow, c.bg),
    DiffDelete = highlight(c.red, c.bg),
    DiffText = highlight(c.blue, c.bg, { bold = true }),
    TelescopeNormal = highlight(c.fg, c.bg),
    TelescopeBorder = highlight(c.cyan, c.bg),
    TelescopeSelection = highlight(c.selection_fg, c.selection_bg, { bold = true }),
    WhichKey = highlight(c.magenta, nil, { bold = true }),
    WhichKeyGroup = highlight(c.cyan, nil),
    WhichKeyDesc = highlight(c.fg, nil),
    WhichKeySeparator = highlight(c.bright_black, nil),
    CmpItemAbbr = highlight(c.fg, nil),
    CmpItemAbbrMatch = highlight(c.cyan, nil, { bold = true }),
    CmpItemKind = highlight(c.magenta, nil),
    NeoTreeNormal = highlight(c.fg, "NONE"),
    NeoTreeNormalNC = highlight(c.fg, "NONE"),
    NeoTreeDirectoryIcon = highlight(c.cyan, nil),
    NeoTreeDirectoryName = highlight(c.blue, nil),

    -- Bufferline has its own groups and does not inherit all base groups.
    BufferLineFill = highlight(c.bright_black, c.bg),
    BufferLineBackground = highlight(c.bright_black, c.bg),
    BufferLineBufferVisible = highlight(c.bright_black, c.bg),
    BufferLineBufferSelected = highlight(c.fg, c.bg, { bold = true, italic = true }),
    BufferLineTab = highlight(c.bright_black, c.bg),
    BufferLineTabSelected = highlight(c.fg, c.bg, { bold = true }),
    BufferLineIndicatorSelected = highlight(c.cyan, c.bg),
    BufferLineSeparator = highlight(c.bright_black, c.bg),
    BufferLineSeparatorSelected = highlight(c.cyan, c.bg),
    BufferLineModified = highlight(c.yellow, c.bg),
    BufferLineModifiedSelected = highlight(c.bright_yellow, c.bg),
    BufferLineError = highlight(c.bright_red, c.bg),
    BufferLineErrorVisible = highlight(c.bright_red, c.bg),
    BufferLineErrorSelected = highlight(c.bright_red, c.bg),
    BufferLineWarning = highlight(c.bright_yellow, c.bg),
    BufferLineWarningVisible = highlight(c.bright_yellow, c.bg),
    BufferLineWarningSelected = highlight(c.bright_yellow, c.bg),
    BufferLineInfo = highlight(c.bright_cyan, c.bg),
    BufferLineInfoVisible = highlight(c.bright_cyan, c.bg),
    BufferLineInfoSelected = highlight(c.bright_cyan, c.bg),
    BufferLineHint = highlight(c.bright_green, c.bg),
    BufferLineHintVisible = highlight(c.bright_green, c.bg),
    BufferLineHintSelected = highlight(c.bright_green, c.bg),
  }

  for group, spec in pairs(groups) do
    vim.api.nvim_set_hl(0, group, spec)
  end

  for index = 0, 15 do
    vim.g["terminal_color_" .. index] = palette.colors[index]
  end

  local lualine = lualine_theme_from(palette)

  for mode, sections in pairs(lualine) do
    for section, spec in pairs(sections) do
      vim.api.nvim_set_hl(0, "lualine_" .. section .. "_" .. mode, spec)
    end
  end

  -- Lualine caches these groups after the first statusline draw. Rebuild their
  -- foreground/background from the freshly applied section colors as well.
  refresh_lualine_transitions()
  vim.cmd("redrawstatus")
end

function M.read()
  return read_palette()
end

function M.lualine_theme()
  local palette = read_palette()
  if not palette then
    return nil
  end

  return lualine_theme_from(palette)
end

function M.apply()
  local palette = read_palette()
  if not palette then
    return false
  end

  set_highlights(palette)
  M.palette = palette
  return true
end

local function schedule_apply()
  if M.reload_timer then
    pcall(function()
      M.reload_timer:stop()
      M.reload_timer:close()
    end)
    M.reload_timer = nil
  end

  M.reload_timer = vim.defer_fn(function()
    M.reload_timer = nil
    M.apply()
  end, 150)
end

local function stop_watcher()
  if not M.watcher then
    return
  end

  pcall(function()
    M.watcher:stop()
  end)
  pcall(function()
    M.watcher:close()
  end)
  M.watcher = nil
end

function M.setup()
  if M.initialized then
    return
  end
  M.initialized = true

  M.apply()

  local group = vim.api.nvim_create_augroup("TerminalPalette", { clear = true })
  vim.api.nvim_create_autocmd({ "VimEnter", "FocusGained" }, {
    group = group,
    callback = function()
      M.apply()
    end,
  })
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = schedule_apply,
  })
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = function()
      stop_watcher()
    end,
  })

  pcall(vim.api.nvim_del_user_command, "TerminalPaletteReload")
  vim.api.nvim_create_user_command("TerminalPaletteReload", function()
    if not M.apply() then
      vim.notify("No se encontró una paleta Kitty generada por Quickshell", vim.log.levels.WARN)
    end
  end, { desc = "Reload the Quickshell/Kitty terminal palette" })

  if not uv or not uv.new_fs_event then
    return
  end

  local path = source_path()
  local watch_dir = vim.fn.fnamemodify(path, ":h")
  if vim.fn.isdirectory(watch_dir) ~= 1 then
    watch_dir = vim.fn.fnamemodify(watch_dir, ":h")
  end
  if vim.fn.isdirectory(watch_dir) ~= 1 then
    return
  end

  local watcher = uv.new_fs_event()
  local ok = pcall(function()
    watcher:start(watch_dir, {}, vim.schedule_wrap(function(err, filename)
      local changed_name = filename and vim.fs.basename(filename) or nil
      if not err and (not changed_name or changed_name == source_name) then
        schedule_apply()
      end
    end))
  end)
  if ok then
    M.watcher = watcher
  else
    pcall(function()
      watcher:close()
    end)
  end
end

return M
