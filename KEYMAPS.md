# ⌨️ NeoVim Keymaps & Cheatsheet

This configuration uses `<Space>` as the `<leader>` key. Below is a comprehensive list of all custom keybindings and useful commands configured in this environment.

---

## 🚀 GitHub Copilot

### Authentication
To use GitHub Copilot, you must authenticate your account the first time you run NeoVim.
Run the following command in normal mode:
```vim
:Copilot auth
```
Follow the instructions provided (it will give you a code and open a browser window to authenticate).

### Copilot Suggestions
When you are in Insert Mode and Copilot provides a suggestion:
| Keybinding | Action |
| --- | --- |
| `<C-l>` | Accept suggestion |
| `<C-j>` | Next suggestion |
| `<C-k>` | Previous suggestion |
| `<C-h>` | Dismiss suggestion |

---

## 🗂️ Buffer Navigation
| Keybinding | Action |
| --- | --- |
| `<Tab>` | Go to next buffer |
| `<S-Tab>` | Go to previous buffer |
| `<leader>1` - `<leader>9` | Go to buffer 1-9 directly |
| `<leader>x` | Close current buffer |

---

## 🔍 Telescope (File & Text Search)
| Keybinding | Action |
| --- | --- |
| `<leader>ff` | Find Files (including hidden ones) |
| `<leader>fg` | Live Grep (Search text across the project) |
| `<leader>fb` | List open Buffers |
| `<leader>gb` | Switch Git Branches |

---

## 🌿 Git Actions

### LazyGit
| Keybinding | Action |
| --- | --- |
| `<leader>lg` | Open LazyGit Interface |

### GitSigns (Inline Git)
| Keybinding | Action |
| --- | --- |
| `]c` | Go to next git hunk (change) |
| `[c` | Go to previous git hunk |
| `<leader>hs` | Stage current hunk (Works in Normal & Visual mode) |
| `<leader>hr` | Reset current hunk (Works in Normal & Visual mode) |
| `<leader>hS` | Stage entire buffer/file |
| `<leader>hR` | Reset entire buffer/file |
| `<leader>hu` | Undo last stage hunk |
| `<leader>hp` | Preview hunk changes |
| `<leader>tb` | Toggle current line Git blame |

### DiffView (Git History & Diffs)
| Keybinding | Action |
| --- | --- |
| `<leader>gd` | Open DiffView |
| `<leader>gc` | Close DiffView |
| `<leader>gh` | View File History |

---

## 🛠️ Code Formatting & Diagnostics

| Keybinding | Action |
| --- | --- |
| `<leader>ft` | Format current buffer (using Conform.nvim) |
| `<leader>d` | View error/diagnostic message in a floating window |
| `]d` | Go to next error/diagnostic |
| `[d` | Go to previous error/diagnostic |

---

## 🌲 File Explorer (Neo-Tree)
| Keybinding | Action |
| --- | --- |
| `<leader>e` | Toggle File Explorer |

---

## 💻 Terminal (ToggleTerm)
| Keybinding | Action |
| --- | --- |
| `<leader>t` | Toggle floating terminal |

---

## 🌐 HTTP Client (Kulala.nvim)
| Keybinding | Action |
| --- | --- |
| `<leader>R` | Run HTTP Request under cursor |
