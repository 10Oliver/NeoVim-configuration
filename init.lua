-- ==========================================================================
-- CONFIGURACIÓN FINAL DE NEOVIM (Fedora 42 / Neovim 0.11 Ready)
-- ==========================================================================

-- 1. CONFIGURACIÓN BÁSICA
vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.clipboard = "unnamedplus" -- Sincroniza con el portapapeles del sistema (requiere wl-clipboard o xclip)
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.updatetime = 250
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- 2. GESTOR DE PLUGINS (LAZY.NVIM)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- TEMA
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night",
        styles = { comments = { italic = true }, keywords = { italic = true } },
      })
      vim.cmd([[colorscheme tokyonight]])
    end,
  },

  -- ICONOS
  "nvim-tree/nvim-web-devicons",

  -- BUFFERLINE
  {
    'akinsho/bufferline.nvim',
    version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",
          numbers = "ordinal",
          diagnostics = "nvim_lsp",
          separator_style = "slant",
          show_buffer_close_icons = false,
          show_close_icon = false,
        }
      })
      for i = 1, 9 do
        vim.keymap.set('n', '<leader>' .. i, function() 
          require("bufferline").go_to(i, true) 
        end, { desc = "Ir al buffer visible " .. i })
      end
      vim.keymap.set('n', '<Tab>', ':BufferLineCycleNext<CR>')
      vim.keymap.set('n', '<S-Tab>', ':BufferLineCyclePrev<CR>')
      vim.keymap.set('n', '<leader>x', ':bdelete<CR>')
      vim.keymap.set('n', '<Tab>', ':BufferLineCycleNext<CR>')
    end
  },
  -- AUTO-PAIRS (Cierra paréntesis y corchetes automágicamente)
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = true
  },
  -- WHICH-KEY (Muestra atajos disponibles en un popup)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300 -- Muestra el menú tras 300ms
    end,
    opts = {}
  },

  -- FORMATEO (Conform.nvim)
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        -- Atajo para formatear manualmente
        "<leader>ft",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = "",
        desc = "Formatear Buffer",
      },
    },
    opts = {
      -- Define tus formateadores por tipo de archivo
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        vue = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
      },
      -- Habilita el formateo al guardar (opcional, pero recomendado)
      format_on_save = nil,
    },
  },

  -- COPILOT
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = {
            accept = "<C-l>",
            next = "<C-j>",
            prev = "<C-k>",
            dismiss = "<C-h>",
          },
        },
        panel = { enabled = false },
      })
    end,
  },

  -- GIT INTEGRATION (MEJORADO)
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require('gitsigns').setup({
        current_line_blame = true,
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navegación (Ir al siguiente cambio)
          map('n', ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
          end, { expr = true })

          map('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
          end, { expr = true })

          -- ACCIONES GIT (Aquí está lo nuevo)
          map('n', '<leader>hs', gs.stage_hunk)       -- Stage pedazo actual
          map('n', '<leader>hr', gs.reset_hunk)       -- Deshacer pedazo actual
          map('v', '<leader>hs', function() gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end) -- Stage selección visual
          map('v', '<leader>hr', function() gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end) -- Reset selección visual
          map('n', '<leader>hR', gs.reset_buffer)     -- Reset archivo COMPLETO
          map('n', '<leader>hS', gs.stage_buffer)     -- Stage archivo COMPLETO
          map('n', '<leader>hu', gs.undo_stage_hunk)  -- Deshacer stage
          map('n', '<leader>hp', gs.preview_hunk)     -- Previsualizar cambio
          map('n', '<leader>tb', gs.toggle_current_line_blame) -- Toggle firma de git
        end
      })
    end
  },
  {
    "sindrets/diffview.nvim",
    keys = {
      -- <leader> es tu tecla Espacio
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Abrir DiffView (Git Diff)" },
      { "<leader>gc", "<cmd>DiffviewClose<cr>", desc = "Cerrar DiffView" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Ver Historial del Archivo Actual" },
    },
  },

  -- BUSCADOR (Telescope)
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Buscar Archivos" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Buscar Texto" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Ver Buffers" },
      { "<leader>gb", "<cmd>Telescope git_branches<cr>", desc = "Cambiar de Rama" },

    },
  },

  -- TREESITTER
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local ok, configs = pcall(require, "nvim-treesitter.configs")
      if not ok then return end
      configs.setup {
        ensure_installed = { "javascript", "typescript", "vue", "php", "html", "css", "lua", "json", "bash" },
        sync_install = false,
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      }
    end
  },

  -- LSP (MASON + CONFIGURACIÓN HÍBRIDA)
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      local mason = require("mason")
      local mason_lspconfig = require("mason-lspconfig")
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      mason.setup()

      -- Función auxiliar para activar servidores sin advertencias
      local function setup_server(server_name, config)
        config = config or {}
        config.capabilities = capabilities
        
        -- Detectamos si es Neovim 0.11+
        if vim.fn.has("nvim-0.11") == 1 then
          vim.lsp.config[server_name] = config
          vim.lsp.enable(server_name)
        else
          require("lspconfig")[server_name].setup(config)
        end
      end

      -- 1. HANDLERS AUTOMÁTICOS
      mason_lspconfig.setup({
        ensure_installed = { "ts_ls", "vue_ls", "intelephense", "html", "cssls", "eslint", "tailwindcss" },
        handlers = {
          function(server_name)
            if server_name ~= "ts_ls" then
              setup_server(server_name)
            end
          end,
          
          ["vue_ls"] = function()
            setup_server("vue_ls")
          end
        }
      })

      -- 2. CONFIGURACIÓN MANUAL DE TS_LS
      local mason_registry_path = vim.fn.stdpath("data") .. "/mason/packages"
      local vue_language_server_path = mason_registry_path .. "/vue-language-server/node_modules/@vue/language-server"

      setup_server("ts_ls", {
        filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
        init_options = {
          plugins = {
            {
              name = "@vue/typescript-plugin",
              location = vue_language_server_path,
              languages = {"vue"},
            },
          },
        },
      })

      -- 3. AUTOCOMPLETADO
      cmp.setup({
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item() elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump() else fallback() end
          end, { 'i', 's' }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
        }, {
          { name = 'buffer' },
        })
      })
    end
  }
})

-- ==========================================
-- ATAJOS PARA DIAGNÓSTICO (ERRORES/LSP)
-- ==========================================

-- Abre el mensaje del error en una ventana flotante (Lo que buscas)
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = "Ver mensaje de error" })

-- Navegar entre errores rápidamente (saltar al siguiente/anterior)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "Ir al error anterior" })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "Ir al siguiente error" })

vim.diagnostic.config({
  virtual_text = true, -- Muestra el error al final de la línea
  signs = true,        -- Muestra el icono a la izquierda
  update_in_insert = false,
  underline = true,
  severity_sort = true,
  float = {
    border = "rounded", -- Borde redondeado para la ventana flotante
    source = "always",  -- Te dice qué herramienta reporta el error (ej: eslint, tsserver)
  },
})
