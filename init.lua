-- Packer Initialization
local packer_ok, packer = pcall(require, "packer")
if not packer_ok then
    print("Packer is not installed. Installing now...")
    local packer_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
    vim.fn.system({"git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", packer_path})
    vim.cmd [[packadd packer.nvim]]
    packer = require("packer")
end

packer.startup(function(use)
    use 'wbthomason/packer.nvim'          -- Packer itself
    use 'github/copilot.vim'              -- GitHub Copilot

    -- Theme Configuration
    use {
        'tanvirtin/monokai.nvim',
        config = function()
            local monokai = require('monokai')
            monokai.setup({
                palette = monokai.pro,
                italics = true
            })
            vim.cmd('colorscheme monokai')
        end
    }
    
    -- GitHub Copilot Configuration
    vim.g.copilot_node_command = "/data/data/com.termux/files/usr/bin/node"

    -- Treesitter for Syntax Highlighting                    
    use {                                                        
        'nvim-treesitter/nvim-treesitter',
        run = function() pcall(vim.cmd, 'TSUpdate') end,
        config = function()
            require'nvim-treesitter.configs'.setup {
                ensure_installed = { "c", "cpp", "lua", "python", "javascript", "html", "css", "bash", "json", "yaml", "markdown" },
                sync_install = false,
                auto_install = true,
                highlight = { enable = true },
                indent = { enable = true }
            }
        end
    }

    -- Lualine for Status Line
    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'nvim-tree/nvim-web-devicons', opt = true },
        config = function()
            require('lualine').setup {
                options = {
                    theme = 'gruvbox',
                    icons_enabled = true,
                    section_separators = '',
                    component_separators = '',
                },
            }
        end
    }

    -- Telescope for Fuzzy Finding
    use {
        'nvim-telescope/telescope.nvim',
        requires = { {'nvim-lua/plenary.nvim'} },
        config = function()
            require('telescope').setup {
                defaults = {
                    file_ignore_patterns = {"node_modules"},
                }
            }
        end
    }

    -- nvim-autopairs for Auto-Closing Brackets and Quotes
    use {
        'windwp/nvim-autopairs',
        config = function()
            require('nvim-autopairs').setup {}
        end
    }

    -- nvim-cmp for Code Completion
    use {
        'hrsh7th/nvim-cmp',
        requires = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-cmdline',
            'hrsh7th/cmp-vsnip',
            'hrsh7th/vim-vsnip'
        },
        config = function()
            local cmp = require'cmp'
            cmp.setup({
                snippet = {
                    expand = function(args)
                        vim.fn["vsnip#anonymous"](args.body)
                    end,
                },
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'vsnip' }
                }, {
                    { name = 'buffer' },
                    { name = 'path' }
                }),
            })
        end
    }

    -- Emmet for HTML/CSS Autocomplete
    use {
        'mattn/emmet-vim',
        config = function()
            vim.g.user_emmet_leader_key = '<C-e>'
        end
    }

    -- Mason (LSP Installer)
    use { 'williamboman/mason.nvim' }
    use { 'williamboman/mason-lspconfig.nvim' }
    use { 'neovim/nvim-lspconfig' }

    -- Prettier for Code Formatting
    use {
        'prettier/vim-prettier',
        run = 'npm install --global prettier',
        cmd = 'Prettier',
        config = function()
            vim.g['prettier#exec_cmd_async'] = 1
        end
    }
end)

-- LSP Configuration
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { 
        "ts_ls", "html", "cssls", "pyright", "bashls",
        "jsonls", "yamlls", "lua_ls", "marksman",
        "rust_analyzer", "dockerls", "svelte",
        "sqls", "terraformls", "cssmodules_ls", "bashls",
        "graphql", "tailwindcss", "texlab", "eslint", "vimls"
    }
})
-- LSP Keybindings
vim.api.nvim_set_keymap('i', '<C-b>', '<C-g>u<C-o>u', { noremap = true, silent = true })

local lspconfig = require('lspconfig')
local lsp_servers = { 
    "ts_ls", "html", "cssls", "pyright", "bashls",
    "jsonls", "yamlls", "lua_ls", "marksman", "rust_analyzer",
    "dockerls", "svelte", "sqls", "terraformls",
    "cssmodules_ls", "graphql", "tailwindcss", "texlab", "eslint",
    "vimls"
}

for _, server in ipairs(lsp_servers) do
    lspconfig[server].setup{}
end

-- Custom Keybindings for Adding Lines (VSCode Style)
vim.api.nvim_set_keymap('n', '<C-j>', 'o', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-k>', 'O', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-j>', '<Esc>o', { noremap = true, silent = true })
-- Auto-Format YAML files with yamlfmt
vim.api.nvim_exec([[
  augroup FormatOnSave
    autocmd!
    autocmd BufWritePre *.yaml,*.yml silent! :!yamlfmt -w %
  augroup END
]], false)
