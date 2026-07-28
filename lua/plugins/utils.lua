return {
  -- AUTO-PAIRS
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = true
  },

  -- AUTOTAG
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require('nvim-ts-autotag').setup()
    end,
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

  -- COPILOT
  -- After installation, authenticate manually from Neovim with: :Copilot auth
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

  -- TELESCOPE
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "List Buffers" },
      { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Find Keymaps" },
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

  -- KULALA (HTTP CLIENT)
  {
    "mistweaverco/kulala.nvim",
    keys = {
      { "<leader>R", "<cmd>lua require('kulala').run()<cr>", desc = "Run HTTP Request" },
    },
    opts = {}
  }
}
