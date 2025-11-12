---
title: "Primeagen Configuration Info"
source: "https://lazyman.dev/info/Primeagen.html"
author:
  - "[[Lazyman]]"
published: 2023-01-01
created: 2025-04-10
description: "The Lazyman project can be used to install, initialize, and manage multiple Neovim configurations. Over 100 popular Neovim configurations are supported."
tags:
  - "clippings"
---
## Primeagen Neovim Configuration Information

[Config from scratch](https://youtu.be/w7i4amO_zaE) by ThePrimeagen

- Install and initialize: **`lazyman -w Primeagen`**
- Configuration category: [Personal](https://lazyman.dev/configurations/#personal-configurations)
- Base configuration: Custom
- Plugin manager: [Packer](https://github.com/wbthomason/packer.nvim)
- Installation location: **`~/.config/nvim-Primeagen`**

## Git repository

[https://github.com/ThePrimeagen/init.lua](https://github.com/ThePrimeagen/init.lua)

## YouTube channel

[https://www.youtube.com/@ThePrimeagen](https://www.youtube.com/@ThePrimeagen)

| Jump | to | Keymaps |
| --- | --- | --- |
| [Normal mode keymaps](https://lazyman.dev/info/#normal-mode-keymaps) | [Visual mode keymaps](https://lazyman.dev/info/#visual-mode-keymaps) | [Operator mode keymaps](https://lazyman.dev/info/#operator-mode-keymaps) |

## Packer managed plugins

- [L3MON4D3/LuaSnip](https://github.com/L3MON4D3/LuaSnip)
- [eandrju/cellular-automaton.nvim](https://github.com/eandrju/cellular-automaton.nvim)
- [laytan/cloak.nvim](https://github.com/laytan/cloak.nvim)
- [hrsh7th/cmp-buffer](https://github.com/hrsh7th/cmp-buffer)
- [hrsh7th/cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp)
- [hrsh7th/cmp-nvim-lua](https://github.com/hrsh7th/cmp-nvim-lua)
- [hrsh7th/cmp-path](https://github.com/hrsh7th/cmp-path)
- [saadparwaiz1/cmp\_luasnip](https://github.com/saadparwaiz1/cmp_luasnip)
- [github/copilot.vim](https://github.com/github/copilot.vim)
- [rafamadriz/friendly-snippets](https://github.com/rafamadriz/friendly-snippets)
- [theprimeagen/harpoon](https://github.com/theprimeagen/harpoon)
- [VonHeikemen/lsp-zero.nvim](https://github.com/VonHeikemen/lsp-zero.nvim)
- [williamboman/mason-lspconfig.nvim](https://github.com/williamboman/mason-lspconfig.nvim)
- [williamboman/mason.nvim](https://github.com/williamboman/mason.nvim)
- [hrsh7th/nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
- [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
- [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- [nvim-treesitter/nvim-treesitter-context](https://github.com/nvim-treesitter/nvim-treesitter-context)
- [wbthomason/packer.nvim](https://github.com/wbthomason/packer.nvim)
- [nvim-treesitter/playground](https://github.com/nvim-treesitter/playground)
- [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- [theprimeagen/refactoring.nvim](https://github.com/theprimeagen/refactoring.nvim)
- [rose-pine/neovim](https://github.com/rose-pine/neovim)
- [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- [folke/trouble.nvim](https://github.com/folke/trouble.nvim)
- [mbbill/undotree](https://github.com/mbbill/undotree)
- [tpope/vim-fugitive](https://github.com/tpope/vim-fugitive)
- [folke/zen-mode.nvim](https://github.com/folke/zen-mode.nvim)

## Primeagen Keymaps

### Normal mode keymaps

| **Description** |  |
| --- | --- |
| **Left hand side** | ` zZ` |
| **Right hand side** |  |

| **Description** |  |
| --- | --- |
| **Left hand side** | ` zz` |
| **Right hand side** |  |

| **Description** |  |
| --- | --- |
| **Left hand side** | ` u` |
| **Right hand side** |  |

| **Description** |  |
| --- | --- |
| **Left hand side** | ` xq` |
| **Right hand side** | `<Cmd>TroubleToggle quickfix<CR>` |

| **Description** |  |
| --- | --- |
| **Left hand side** | ` vh` |
| **Right hand side** |  |

| **Description** |  |
| --- | --- |
| **Left hand side** | ` ps` |
| **Right hand side** |  |

| **Description** |  |
| --- | --- |
| **Left hand side** | ` pf` |
| **Right hand side** |  |

| **Description** |  |
| --- | --- |
| **Left hand side** | ` a` |
| **Right hand side** |  |

| **Description** |  |
| --- | --- |
| **Left hand side** | ` gs` |
| **Right hand side** |  |

| **Description** |  |
| --- | --- |
| **Left hand side** | ` mr` |
| **Right hand side** | `<Cmd>CellularAutomaton make_it_rain<CR>` |

| **Description** |  |
| --- | --- |
| **Left hand side** | ` vpp` |
| **Right hand side** | `<Cmd>e ~/.config/nvim-Primeagen/lua/theprimeagen/packer.lua<CR>` |

| **Description** |  |
| --- | --- |
| **Left hand side** | ` x` |
| **Right hand side** | `<Cmd>!chmod +x %<CR>` |

| **Description** |  |
| --- | --- |
| **Left hand side** | ` s` |
| **Right hand side** | `:%s/\<lt><C-R><C-W>\>/<C-R><C-W>/gI<Left><Left><Left>` |

| **Description** |  |
| --- | --- |
| **Left hand side** | ` j` |
| **Right hand side** | `<Cmd>lprev<CR>zz` |

| **Description** |  |
| --- | --- |
| **Left hand side** | ` k` |
| **Right hand side** | `<Cmd>lnext<CR>zz` |

| **Description** |  |
| --- | --- |
| **Left hand side** | ` f` |
| **Right hand side** |  |

| **Description** |  |
| --- | --- |
| **Left hand side** | ` d` |
| **Right hand side** | `"_d` |

| **Description** |  |
| --- | --- |
| **Left hand side** | ` Y` |
| **Right hand side** | `"+Y` |

| **Description** |  |
| --- | --- |
| **Left hand side** | ` y` |
| **Right hand side** | `"+y` |

| **Description** |  |
| --- | --- |
| **Left hand side** | ` svwm` |
| **Right hand side** |  |

| **Description** |  |
| --- | --- |
| **Left hand side** | ` vwm` |
| **Right hand side** |  |

| **Description** |  |
| --- | --- |
| **Left hand side** | ` pv` |
| **Right hand side** |  |

| **Description** |  |
| --- | --- |
| **Left hand side** | `%` |
| **Right hand side** | `<Plug>(MatchitNormalForward)` |

| **Description** | Nvim builtin |
| --- | --- |
| **Left hand side** | `&` |
| **Right hand side** | `:&&<CR>` |

| **Description** |  |
| --- | --- |
| **Left hand side** | `J` |
| **Right hand side** | ``mzJ`z`` |

| **Description** |  |
| --- | --- |
| **Left hand side** | `N` |
| **Right hand side** | `Nzzzv` |

| **Description** |  |
| --- | --- |
| **Left hand side** | `Q` |
| **Right hand side** |  |

| **Description** | Nvim builtin |
| --- | --- |
| **Left hand side** | `Y` |
| **Right hand side** | `y$` |

| **Description** |  |
| --- | --- |
| **Left hand side** | `[%` |
| **Right hand side** | `<Plug>(MatchitNormalMultiBackward)` |

| **Description** |  |
| --- | --- |
| **Left hand side** | `]%` |
| **Right hand side** | `<Plug>(MatchitNormalMultiForward)` |

| **Description** |  |
| --- | --- |
| **Left hand side** | `gx` |
| **Right hand side** | `<Plug>NetrwBrowseX` |

| **Description** |  |
| --- | --- |
| **Left hand side** | `g%` |
| **Right hand side** | `<Plug>(MatchitNormalBackward)` |

| **Description** |  |
| --- | --- |
| **Left hand side** | `n` |
| **Right hand side** | `nzzzv` |

| **Description** |  |
| --- | --- |
| **Left hand side** | `y<C-G>` |
| **Right hand side** | `:<C-U>call setreg(v:register, fugitive#Object(@%))<CR>` |

| **Description** |  |
| --- | --- |
| **Left hand side** | `<C-P>` |
| **Right hand side** |  |

| **Description** |  |
| --- | --- |
| **Left hand side** | `<C-S>` |
| **Right hand side** |  |

| **Description** |  |
| --- | --- |
| **Left hand side** | `<C-N>` |
| **Right hand side** |  |

| **Description** |  |
| --- | --- |
| **Left hand side** | `<C-T>` |
| **Right hand side** |  |

| **Description** |  |
| --- | --- |
| **Left hand side** | `<C-H>` |
| **Right hand side** |  |

| **Description** |  |
| --- | --- |
| **Left hand side** | `<C-E>` |
| **Right hand side** |  |

| **Description** |  |
| --- | --- |
| **Left hand side** | `<Plug>fugitive:` |
| **Right hand side** |  |

| **Description** |  |
| --- | --- |
| **Left hand side** | `<Plug>fugitive:y<C-G>` |
| **Right hand side** | `:<C-U>call setreg(v:register, fugitive#Object(@%))<CR>` |

| **Description** |  |
| --- | --- |
| **Left hand side** | `<Plug>PlenaryTestFile` |
| **Right hand side** | `:lua require('plenary.test_harness').test_directory(vim.fn.expand("%:p"))<CR>` |

| **Description** |  |
| --- | --- |
| **Left hand side** | `<Plug>luasnip-expand-repeat` |
| **Right hand side** |  |

| **Description** |  |
| --- | --- |
| **Left hand side** | `<Plug>luasnip-delete-check` |
| **Right hand side** |  |

| **Description** |  |
| --- | --- |
| **Left hand side** | `<Plug>NetrwBrowseX` |
| **Right hand side** | `:call netrw#BrowseX(netrw#GX(),netrw#CheckIfRemote(netrw#GX()))<CR>` |

| **Description** |  |
| --- | --- |
| **Left hand side** | `<Plug>(MatchitNormalMultiForward)` |
| **Right hand side** | `:<C-U>call matchit#MultiMatch("W", "n")<CR>` |

| **Description** |  |
| --- | --- |
| **Left hand side** | `<Plug>(MatchitNormalMultiBackward)` |
| **Right hand side** | `:<C-U>call matchit#MultiMatch("bW", "n")<CR>` |

| **Description** |  |
| --- | --- |
| **Left hand side** | `<Plug>(MatchitNormalBackward)` |
| **Right hand side** | `:<C-U>call matchit#Match_wrapper('',0,'n')<CR>` |

| **Description** |  |
| --- | --- |
| **Left hand side** | `<Plug>(MatchitNormalForward)` |
| **Right hand side** | `:<C-U>call matchit#Match_wrapper('',1,'n')<CR>` |

| **Description** |  |
| --- | --- |
| **Left hand side** | `<C-J>` |
| **Right hand side** | `<Cmd>cprev<CR>zz` |

| **Description** |  |
| --- | --- |
| **Left hand side** | `<C-K>` |
| **Right hand side** | `<Cmd>cnext<CR>zz` |

| **Description** |  |
| --- | --- |
| **Left hand side** | `<C-F>` |
| **Right hand side** | `<Cmd>silent !tmux neww tmux-sessionizer<CR>` |

| **Description** |  |
| --- | --- |
| **Left hand side** | `<C-U>` |
| **Right hand side** | `<C-U>zz` |

| **Description** |  |
| --- | --- |
| **Left hand side** | `<C-D>` |
| **Right hand side** | `<C-D>zz` |

| **Description** | Nvim builtin |
| --- | --- |
| **Left hand side** | `<C-L>` |
| **Right hand side** | `<Cmd>nohlsearch\|diffupdate\|normal! <C-L><CR>` |

### Visual mode keymaps

| **Description** |  |
| --- | --- |
| **Left hand side** | ` ri` |
| **Right hand side** | ` <Esc><Cmd>lua require('refactoring').refactor('Inline Variable')<CR>` |

| **Description** |  |
| --- | --- |
| **Left hand side** | ` d` |
| **Right hand side** | `"_d` |

| **Description** |  |
| --- | --- |
| **Left hand side** | ` y` |
| **Right hand side** | `"+y` |

| **Description** |  |
| --- | --- |
| **Left hand side** | ` p` |
| **Right hand side** | `"_dP` |

| **Description** | Nvim builtin |
| --- | --- |
| **Left hand side** | `#` |
| **Right hand side** | `y?\V<C-R>"<CR>` |

| **Description** |  |
| --- | --- |
| **Left hand side** | `%` |
| **Right hand side** | `<Plug>(MatchitVisualForward)` |

| **Description** | Nvim builtin |
| --- | --- |
| **Left hand side** | `*` |
| **Right hand side** | `y/\V<C-R>"<CR>` |

| **Description** |  |
| --- | --- |
| **Left hand side** | `J` |
| **Right hand side** | `:m '>+1<CR>gv=gv` |

| **Description** |  |
| --- | --- |
| **Left hand side** | `K` |
| **Right hand side** | `:m '<lt>-2<CR>gv=gv` |

| **Description** |  |
| --- | --- |
| **Left hand side** | `[%` |
| **Right hand side** | `<Plug>(MatchitVisualMultiBackward)` |

| **Description** |  |
| --- | --- |
| **Left hand side** | `]%` |
| **Right hand side** | `<Plug>(MatchitVisualMultiForward)` |

| **Description** |  |
| --- | --- |
| **Left hand side** | `a%` |
| **Right hand side** | `<Plug>(MatchitVisualTextObject)` |

| **Description** |  |
| --- | --- |
| **Left hand side** | `gx` |
| **Right hand side** | `<Plug>NetrwBrowseXVis` |

| **Description** |  |
| --- | --- |
| **Left hand side** | `g%` |
| **Right hand side** | `<Plug>(MatchitVisualBackward)` |

| **Description** |  |
| --- | --- |
| **Left hand side** | `<Plug>luasnip-expand-repeat` |
| **Right hand side** |  |

| **Description** |  |
| --- | --- |
| **Left hand side** | `<Plug>NetrwBrowseXVis` |
| **Right hand side** | `:<C-U>call netrw#BrowseXVis()<CR>` |

| **Description** |  |
| --- | --- |
| **Left hand side** | `<Plug>(MatchitVisualTextObject)` |
| **Right hand side** | `<Plug>(MatchitVisualMultiBackward)o<Plug>(MatchitVisualMultiForward)` |

| **Description** |  |
| --- | --- |
| **Left hand side** | `<Plug>(MatchitVisualMultiForward)` |
| **Right hand side** | ` :<C-U>call matchit#MultiMatch("W", "n")<CR>m'gv`` ` |

| **Description** |  |
| --- | --- |
| **Left hand side** | `<Plug>(MatchitVisualMultiBackward)` |
| **Right hand side** | ` :<C-U>call matchit#MultiMatch("bW", "n")<CR>m'gv`` ` |

| **Description** |  |
| --- | --- |
| **Left hand side** | `<Plug>(MatchitVisualBackward)` |
| **Right hand side** | ` :<C-U>call matchit#Match_wrapper('',0,'v')<CR>m'gv`` ` |

| **Description** |  |
| --- | --- |
| **Left hand side** | `<Plug>(MatchitVisualForward)` |
| **Right hand side** | ` :<C-U>call matchit#Match_wrapper('',1,'v')<CR>:if col("''") != col("$") \| exe ":normal! m'" \| endif<CR>gv`` ` |

### Operator mode keymaps

| **Description** |  |
| --- | --- |
| **Left hand side** | `%` |
| **Right hand side** | `<Plug>(MatchitOperationForward)` |

| **Description** |  |
| --- | --- |
| **Left hand side** | `[%` |
| **Right hand side** | `<Plug>(MatchitOperationMultiBackward)` |

| **Description** |  |
| --- | --- |
| **Left hand side** | `]%` |
| **Right hand side** | `<Plug>(MatchitOperationMultiForward)` |

| **Description** |  |
| --- | --- |
| **Left hand side** | `g%` |
| **Right hand side** | `<Plug>(MatchitOperationBackward)` |

| **Description** |  |
| --- | --- |
| **Left hand side** | `<Plug>luasnip-expand-repeat` |
| **Right hand side** |  |

| **Description** |  |
| --- | --- |
| **Left hand side** | `<Plug>(MatchitOperationMultiForward)` |
| **Right hand side** | `:<C-U>call matchit#MultiMatch("W", "o")<CR>` |

| **Description** |  |
| --- | --- |
| **Left hand side** | `<Plug>(MatchitOperationMultiBackward)` |
| **Right hand side** | `:<C-U>call matchit#MultiMatch("bW", "o")<CR>` |

| **Description** |  |
| --- | --- |
| **Left hand side** | `<Plug>(MatchitOperationBackward)` |
| **Right hand side** | `:<C-U>call matchit#Match_wrapper('',0,'o')<CR>` |

| **Description** |  |
| --- | --- |
| **Left hand side** | `<Plug>(MatchitOperationForward)` |
| **Right hand side** | `:<C-U>call matchit#Match_wrapper('',1,'o')<CR>` |