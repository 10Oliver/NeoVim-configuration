return {
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
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- LUALINE (STATUS LINE)
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = { theme = "tokyonight" }
      })
    end
  },

  -- BUFFERLINE
  {
    'akinsho/bufferline.nvim',
    version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers", numbers = "ordinal", diagnostics = "nvim_lsp",
          separator_style = "slant", show_buffer_close_icons = false, show_close_icon = false,
        }
      })
      for i = 1, 9 do
        vim.keymap.set('n', '<leader>' .. i, function() require("bufferline").go_to(i, true) end, { desc = "Go to visible buffer " .. i })
      end
      vim.keymap.set('n', '<Tab>', '<cmd>BufferLineCycleNext<cr>')
      vim.keymap.set('n', '<S-Tab>', '<cmd>BufferLineCyclePrev<cr>')
      vim.keymap.set('n', '<leader>x', '<cmd>bdelete<cr>', { desc = "Close Buffer" })
    end
  },

  -- NEO-TREE (FILE EXPLORER)
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle File Explorer" },
    },
    opts = {
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
    }
  },

  -- TOGGLETERM (TERMINAL)
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { "<leader>t", "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal" },
    },
    config = function()
      require("toggleterm").setup({
        size = 20,
        open_mapping = [[<leader>t]],
        hide_numbers = true,
        shade_filetypes = {},
        shade_terminals = true,
        shading_factor = 2,
        start_in_insert = true,
        insert_mappings = true,
        persist_size = true,
        direction = "float",
        close_on_exit = true,
        shell = vim.o.shell,
      })
    end
  },

  -- COLORIZER (TAILWIND/HEX)
  {
    "NvChad/nvim-colorizer.lua",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("colorizer").setup({
        user_default_options = {
          tailwind = true,
        }
      })
    end
  },
}
