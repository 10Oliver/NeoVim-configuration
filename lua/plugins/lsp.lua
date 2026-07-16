return {
  -- Conform.nvim
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      { "<leader>ft", function() require("conform").format({ async = true, lsp_fallback = true }) end, mode = "", desc = "Format Buffer" },
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

  -- VUE TRADITIONAL SYNTAX (Fallback for huge files)
  {
    "posva/vim-vue",
    ft = "vue",
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "vue",
        command = "syntax sync fromstart",
      })
    end
  },

  -- TREESITTER
  {
    "nvim-treesitter/nvim-treesitter",
    tag = "v0.9.3",
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local ok, configs = pcall(require, "nvim-treesitter.configs")
      if not ok then return end
      configs.setup {
        ensure_installed = { "javascript", "typescript", "vue", "svelte", "angular", "php", "html", "css", "lua", "json", "bash", "markdown", "markdown_inline" },
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
      capabilities.workspace = capabilities.workspace or {}
      capabilities.workspace.didChangeWatchedFiles = {
        dynamicRegistration = false,
      }

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
          ['<PageUp>'] = cmp.mapping.scroll_docs(-4),
          ['<PageDown>'] = cmp.mapping.scroll_docs(4),
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
}
