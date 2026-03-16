-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Leader must be set before lazy
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- ── Core Options ──────────────────────────────────────────────────────

vim.opt.autoread = true
vim.opt.clipboard = "unnamedplus"
vim.opt.encoding = "utf-8"
vim.opt.hidden = true
vim.opt.swapfile = false
vim.opt.writebackup = false

vim.opt.laststatus = 2
vim.opt.wrap = false
vim.opt.number = true
vim.opt.scrolloff = 3
vim.opt.showcmd = true
vim.opt.sidescroll = 3
vim.opt.signcolumn = "yes"
vim.opt.splitright = true
vim.opt.mouse = "a"
vim.opt.visualbell = true
vim.opt.wildmenu = true
vim.opt.wildignore = "*.pyc"
vim.opt.termguicolors = true

vim.opt.backspace = "2"
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.cindent = true
vim.opt.smarttab = true
vim.opt.softtabstop = 4
vim.opt.tabstop = 4

vim.opt.showmatch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true

-- ── Plugins ───────────────────────────────────────────────────────────

require("lazy").setup({
  -- Colorscheme
  {
    "nanotech/jellybeans.vim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("jellybeans")
    end,
  },

  -- Git
  {
    "tpope/vim-fugitive",
    cmd = "Git",
    keys = {
      { "<leader>gs", "<cmd>Git<cr>", desc = "Git status" },
      { "<leader>gd", "<cmd>Gdiffsplit<cr>", desc = "Git diff" },
      { "<leader>gp", "<cmd>Git push<cr>", desc = "Git push" },
    },
  },

  -- Commenting
  { "numToStr/Comment.nvim", opts = {}, event = "VeryLazy" },

  -- Surround
  { "kylechui/nvim-surround", version = "*", event = "VeryLazy", opts = {} },

  -- Fuzzy finder
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<C-p>", function() require("fzf-lua").files() end, desc = "Find files" },
      { "<leader>f", function() require("fzf-lua").live_grep() end, desc = "Live grep" },
      { "<leader>b", function() require("fzf-lua").buffers() end, desc = "Buffers" },
    },
    opts = {},
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter").setup({
        ensure_installed = {
          "lua", "python", "typescript", "javascript", "tsx",
          "json", "html", "css", "bash", "markdown", "swift", "kotlin",
          "vim", "vimdoc", "yaml", "toml",
        },
      })
    end,
  },

  -- LSP
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    opts = {},
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      ensure_installed = { "pyright", "ts_ls", "kotlin_language_server", "lua_ls" },
    },
    config = function(_, opts)
      require("mason-lspconfig").setup(opts)

      local capabilities = require("blink.cmp").get_lsp_capabilities()

      -- Servers with default settings
      for _, server in ipairs({ "pyright", "ts_ls", "kotlin_language_server", "sourcekit" }) do
        vim.lsp.config(server, { capabilities = capabilities })
      end

      -- lua_ls with custom settings
      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      })

      vim.lsp.enable({ "pyright", "ts_ls", "kotlin_language_server", "lua_ls", "sourcekit" })
    end,
  },

  -- Completion
  {
    "saghen/blink.cmp",
    version = "*",
    event = "InsertEnter",
    opts = {
      keymap = { preset = "default" },
      sources = {
        default = { "lsp", "path", "buffer" },
      },
    },
  },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = {
      options = {
        theme = "jellybeans",
        section_separators = "",
        component_separators = "|",
      },
    },
  },

  -- Tmux navigation
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
  },
}, {
  install = { colorscheme = { "jellybeans" } },
  checker = { enabled = false },
})

-- ── Keymaps ───────────────────────────────────────────────────────────

vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set("n", ";", ":")
vim.keymap.set("n", "<C-n>", "<cmd>nohlsearch<cr>")

-- Prevent overwriting default register when inconvenient
vim.keymap.set("v", "x", '"_x')
vim.keymap.set("v", "c", '"_c')
vim.keymap.set("v", "p", '"_dP')

-- Buffer navigation
vim.keymap.set("n", "[b", "<cmd>bp<cr>")
vim.keymap.set("n", "]b", "<cmd>bn<cr>")
vim.keymap.set("n", "<leader>d", "<cmd>bd!<cr>")

-- Git (fugitive close diff helper)
vim.keymap.set("n", "<leader>gf", "<C-W>h<C-W>czR")

-- Edit and reload config
vim.keymap.set("n", "<leader>r", "<cmd>edit $MYVIMRC<cr>")
vim.keymap.set("n", "<leader>R", "<cmd>source $MYVIMRC<cr>")

-- ── Autocommands ──────────────────────────────────────────────────────

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- LSP keymaps
autocmd("LspAttach", {
  group = augroup("lsp_keymaps", { clear = true }),
  callback = function(ev)
    local map = function(keys, func, desc)
      vim.keymap.set("n", keys, func, { buffer = ev.buf, desc = desc })
    end
    map("gd", vim.lsp.buf.definition, "Go to definition")
    map("gr", vim.lsp.buf.references, "References")
    map("K", vim.lsp.buf.hover, "Hover")
    map("<leader>ca", vim.lsp.buf.code_action, "Code action")
    map("<leader>rn", vim.lsp.buf.rename, "Rename")
    map("[d", vim.diagnostic.goto_prev, "Prev diagnostic")
    map("]d", vim.diagnostic.goto_next, "Next diagnostic")
  end,
})

-- Smaller indents for web files
autocmd("FileType", {
  group = augroup("web_indent", { clear = true }),
  pattern = { "css", "html", "javascript", "typescript", "typescriptreact", "javascriptreact" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
  end,
})

-- Git commit settings
autocmd("FileType", {
  group = augroup("gitcommit_settings", { clear = true }),
  pattern = "gitcommit",
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.textwidth = 72
  end,
})

-- Remove trailing whitespace on save
autocmd("BufWritePre", {
  group = augroup("trim_whitespace", { clear = true }),
  pattern = "*",
  callback = function()
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd([[%s/\s\+$//e]])
    vim.api.nvim_win_set_cursor(0, pos)
  end,
})
