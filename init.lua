-- BASIC CONFIGURATION
vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.clipboard = "unnamedplus"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.updatetime = 250
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true

-- LAZY.NVIM
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- THEME
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

  -- ICONS
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
        end, { desc = "Go to visible buffer " .. i })
      end
      vim.keymap.set('n', '<Tab>', ':BufferLineCycleNext<CR>')
      vim.keymap.set('n', '<S-Tab>', ':BufferLineCyclePrev<CR>')
      vim.keymap.set('n', '<leader>x', ':bdelete<CR>')
    end
  },
  -- AUTO-PAIRS
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = true
  },
  -- WHICH-KEY
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {}
  },

  -- Conform.nvim
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>ft",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = "",
        desc = "Format Buffer",
      },
    },
    opts = {
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
        svelte = { "prettier" },
        angular = { "prettier" },
      },
      formatters = {
        prettier = {
          prepend_args = { "--single-attribute-per-line" },
        },
      },
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

  -- GITSIGNS
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

          -- GIT ACTIONS
          map('n', '<leader>hs', gs.stage_hunk)
          map('n', '<leader>hr', gs.reset_hunk)
          map('v', '<leader>hs', function() gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
          map('v', '<leader>hr', function() gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
          map('n', '<leader>hR', gs.reset_buffer)
          map('n', '<leader>hS', gs.stage_buffer)
          map('n', '<leader>hu', gs.undo_stage_hunk)
          map('n', '<leader>hp', gs.preview_hunk)
          map('n', '<leader>tb', gs.toggle_current_line_blame)
        end
      })
    end
  },
  {
    "sindrets/diffview.nvim",
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "DiffView" },
      { "<leader>gc", "<cmd>DiffviewClose<cr>", desc = "Close DiffView" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File History" },
    },
  },

  -- TELESCOPE
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "List Buffers" },
      { "<leader>gb", "<cmd>Telescope git_branches<cr>", desc = "Git Branches" },
    },
    opts = {
      defaults = {
          file_ignore_patterns = { "%.git/", "node_modules/", "vendor/" }
      },
      pickers = {
        find_files = {
          hidden = true,
          no_ignore = true,
        },
        live_grep = {
          additional_args = function()
            return { "--hidden", "--no-ignore" }
          end,
        },
      },
    },
  },
  -- LAZYGIT
  {
    "kdheepak/lazygit.nvim",
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>lg", "<cmd>LazyGit<cr>", desc = "Open LazyGit" },
    },
  },

  -- UI & FRAMEWORKS (Tailwind, Autotag, etc.)
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require('nvim-ts-autotag').setup()
    end,
  },
  {
    "NvChad/nvim-colorizer.lua",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("colorizer").setup({
        user_default_options = {
          tailwind = true, -- Enable tailwind colors
        }
      })
    end
  },

  -- VUE TRADITIONAL SYNTAX (Fallback for huge files)
  {
    "posva/vim-vue",
    ft = "vue",
    config = function()
      -- Sync from start so it doesn't lose color when scrolling
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "vue",
        command = "syntax sync fromstart",
      })
    end
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
        ensure_installed = { "javascript", "typescript", "vue", "svelte", "angular", "php", "html", "css", "lua", "json", "bash" },
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
          disable = function(lang, buf)
            local max_filesize = 100 * 1024 -- 100 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
              return true
            end
          end,
        },
        indent = { enable = true },
      }
    end
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
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

      -- Automatically install formatters
      require('mason-tool-installer').setup({
        ensure_installed = {
          'prettier',
          'stylua',
        },
      })

      local function setup_server(server_name, config)
        config = config or {}
        config.capabilities = capabilities
        
        if vim.fn.has("nvim-0.11") == 1 then
          vim.lsp.config[server_name] = config
          vim.lsp.enable(server_name)
        else
          require("lspconfig")[server_name].setup(config)
        end
      end

      -- 1. AUTOMATIC HANDLERS
      mason_lspconfig.setup({
        ensure_installed = { "ts_ls", "vue_ls", "svelte", "angularls", "intelephense", "html", "cssls", "eslint", "tailwindcss" },
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

      -- 2. MANUAL TS_LS CONFIGURATION
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

      -- 3. AUTOCOMPLETION
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

-- DIAGNOSTICS
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = "View error message" })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "Go to previous error" })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "Go to next error" })

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  update_in_insert = false,
  underline = true,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "always",
  },
})
