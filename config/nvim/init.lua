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
      -- OLED overrides: pure black backgrounds, softer contrast
      local bg = "#000000"
      vim.api.nvim_set_hl(0, "Normal", { bg = bg })
      vim.api.nvim_set_hl(0, "NormalNC", { bg = bg })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = bg })
      vim.api.nvim_set_hl(0, "SignColumn", { bg = bg })
      vim.api.nvim_set_hl(0, "LineNr", { fg = "#3a3a3a", bg = bg })
      vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#7a9f9f", bg = bg, bold = true })
      vim.api.nvim_set_hl(0, "EndOfBuffer", { fg = bg, bg = bg })
      vim.api.nvim_set_hl(0, "StatusLine", { fg = "#b0b0b0", bg = bg })
      vim.api.nvim_set_hl(0, "StatusLineNC", { fg = "#3a3a3a", bg = bg })
      vim.api.nvim_set_hl(0, "VertSplit", { fg = "#1a1a1a", bg = bg })
      vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#1a1a1a", bg = bg })
      vim.api.nvim_set_hl(0, "Pmenu", { fg = "#b0b0b0", bg = "#0a0a0a" })
      vim.api.nvim_set_hl(0, "PmenuSel", { fg = "#000000", bg = "#7a9f9f" })
      vim.api.nvim_set_hl(0, "CursorLine", { bg = "#0a0a0a" })
      vim.api.nvim_set_hl(0, "Visual", { bg = "#1a3a3a" })
      vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#3a3a3a", bg = bg })
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
    config = function()
      local oled_theme = require("lualine.themes.jellybeans")
      -- Force all lualine backgrounds to pure black
      for _, mode in pairs(oled_theme) do
        for _, section in pairs(mode) do
          if type(section) == "table" and section.bg then
            section.bg = "#000000"
          end
        end
      end
      require("lualine").setup({
        options = {
          theme = oled_theme,
          section_separators = "",
          component_separators = "|",
        },
      })
    end,
  },

  -- Tmux navigation
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
  },

  -- ── Git Enhancement ─────────────────────────────────────────────────

  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local map = function(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end
        map("n", "]c", function()
          if vim.wo.diff then return "]c" end
          vim.schedule(function() gs.nav_hunk("next") end)
          return "<Ignore>"
        end, "Next hunk")
        map("n", "[c", function()
          if vim.wo.diff then return "[c" end
          vim.schedule(function() gs.nav_hunk("prev") end)
          return "<Ignore>"
        end, "Prev hunk")
        map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
        map("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")
        map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>tb", gs.toggle_current_line_blame, "Toggle line blame")
      end,
    },
  },

  -- ── Formatting ──────────────────────────────────────────────────────

  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    opts = {
      formatters_by_ft = {
        python = { "ruff_format" },
        typescript = { "prettier" },
        javascript = { "prettier" },
        typescriptreact = { "prettier" },
        javascriptreact = { "prettier" },
        lua = { "stylua" },
        swift = { "swiftformat" },
        kotlin = { "ktlint" },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_format = "fallback",
      },
    },
  },

  -- ── Linting ─────────────────────────────────────────────────────────

  {
    "mfussenegger/nvim-lint",
    event = { "BufWritePost", "BufReadPost" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        python = { "ruff" },
        swift = { "swiftlint" },
      }
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
        group = vim.api.nvim_create_augroup("nvim_lint", { clear = true }),
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },

  -- ── Diagnostics Panel ───────────────────────────────────────────────

  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Workspace diagnostics" },
      { "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Document diagnostics" },
    },
    opts = {},
  },

  -- ── Keybinding Discovery ───────────────────────────────────────────

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>g", group = "git" },
        { "<leader>h", group = "hunks" },
        { "<leader>x", group = "diagnostics" },
        { "<leader>c", group = "code" },
        { "<leader>t", group = "toggle" },
      },
    },
  },

  -- ── Lua LSP Enhancement ────────────────────────────────────────────

  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },

  -- ── File Explorer ──────────────────────────────────────────────────

  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>e", "<cmd>Oil<cr>", desc = "Open file explorer" },
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
    },
    opts = {
      view_options = {
        show_hidden = true,
      },
    },
  },

  -- ── Motion ─────────────────────────────────────────────────────────

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    },
    opts = {},
  },

  -- ── File Bookmarks ─────────────────────────────────────────────────

  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>a", function() require("harpoon"):list():add() end, desc = "Harpoon add file" },
      { "<leader>1", function() require("harpoon"):list():select(1) end, desc = "Harpoon file 1" },
      { "<leader>2", function() require("harpoon"):list():select(2) end, desc = "Harpoon file 2" },
      { "<leader>3", function() require("harpoon"):list():select(3) end, desc = "Harpoon file 3" },
      { "<leader>4", function() require("harpoon"):list():select(4) end, desc = "Harpoon file 4" },
    },
    config = function()
      require("harpoon"):setup()
    end,
  },

  -- ── Utility Bundle ─────────────────────────────────────────────────

  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      dashboard = { enabled = true },
      notifier = { enabled = true },
      indent = { enabled = true },
      words = { enabled = true },
      terminal = { enabled = true },
    },
    keys = {
      { "<leader>d", function() Snacks.bufdelete() end, desc = "Delete buffer" },
      { "<leader>tt", function() Snacks.terminal() end, desc = "Toggle terminal" },
    },
  },

  -- ── AI Assistant ──────────────────────────────────────────────────

  {
    "nickjvandyke/opencode.nvim",
    cmd = "OpenCode",
    keys = {
      { "<leader>o", "<cmd>OpenCode<cr>", desc = "Open OpenCode" },
    },
  },

  -- ── Markdown Rendering ─────────────────────────────────────────────

  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ft = "markdown",
    opts = {},
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
-- <leader>d mapped to Snacks.bufdelete() in plugin config

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
