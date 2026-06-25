-- DIAGNOSTICS KEYMAPS
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = "View error message" })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "Go to previous error" })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "Go to next error" })
