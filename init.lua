vim.g.mapleader = " "

-- Plugins
vim.pack.add({
  "https://github.com/folke/tokyonight.nvim",
  "https://github.com/stevearc/oil.nvim",
  "https://github.com/hrsh7th/nvim-cmp",
  "https://github.com/hrsh7th/cmp-nvim-lsp",
  "https://github.com/hrsh7th/cmp-buffer",
  "https://github.com/hrsh7th/cmp-path",
  "https://github.com/L3MON4D3/LuaSnip",
  "https://github.com/saadparwaiz1/cmp_luasnip",
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/nvim-telescope/telescope.nvim",
})

-- Basic options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.mouse = "a"

vim.opt.expandtab = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

vim.opt.clipboard = "unnamedplus"

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.splitright = true
vim.opt.splitbelow = true

-- Theme
require("tokyonight").setup({
  style = "night",
  transparent = false,
  terminal_colors = true,

  styles = {
    comments = { italic = true },
    keywords = { italic = false },
    functions = {},
    variables = {},
  },

  sidebars = {
    "qf",
    "help",
    "terminal",
  },

  dim_inactive = false,
})

vim.cmd.colorscheme("tokyonight")

-- Diagnostics
vim.diagnostic.config({
  virtual_text = true,
  underline = true,
  signs = true,
  update_in_insert = false,
  severity_sort = true,
})

-- Telescope
local telescope = require("telescope")
local telescope_builtin = require("telescope.builtin")

telescope.setup({
  defaults = {
    path_display = { "smart" },

    file_ignore_patterns = {
      "node_modules",
      ".git/",
      "vendor",
      "dist",
      "build",
    },

    mappings = {
      i = {
        ["<C-j>"] = "move_selection_next",
        ["<C-k>"] = "move_selection_previous",
      },
    },
  },

  pickers = {
    find_files = {
      hidden = true,
    },
  },
})

vim.keymap.set("n", "<leader>ff", telescope_builtin.find_files, {
  silent = true,
  desc = "Find files",
})

vim.keymap.set("n", "<leader>fg", telescope_builtin.live_grep, {
  silent = true,
  desc = "Live grep",
})

vim.keymap.set("n", "<leader>fb", telescope_builtin.buffers, {
  silent = true,
  desc = "Find buffers",
})

vim.keymap.set("n", "<leader>fh", telescope_builtin.help_tags, {
  silent = true,
  desc = "Find help",
})

-- Explorer
require("oil").setup({
  default_file_explorer = true,

  columns = {
    "icon",
  },

  view_options = {
    show_hidden = true,
  },

  skip_confirm_for_simple_edits = false,

  keymaps = {
    ["<CR>"] = "actions.select",
    ["-"] = "actions.parent",
    ["_"] = "actions.open_cwd",
    ["g."] = "actions.toggle_hidden",
    ["q"] = "actions.close",
  },
})

vim.keymap.set("n", "<leader>e", "<cmd>Oil<CR>", {
  silent = true,
  desc = "Open Oil file explorer",
})
-- Completion
local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },

  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),

    ["<CR>"] = cmp.mapping.confirm({
      select = false,
    }),

    ["<C-j>"] = cmp.mapping.select_next_item({
      behavior = cmp.SelectBehavior.Select,
    }),

    ["<C-k>"] = cmp.mapping.select_prev_item({
      behavior = cmp.SelectBehavior.Select,
    }),

    ["<Tab>"] = cmp.mapping(function(fallback)
      if luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),

  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "path" },
    { name = "luasnip" },
  }, {
    { name = "buffer" },
  }),
})

-- LSP capabilities for nvim-cmp
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Go LSP
vim.lsp.config("gopls", {
  cmd = { "gopls" },

  filetypes = {
    "go",
    "gomod",
    "gowork",
    "gosum",
  },

  root_markers = {
    "go.work",
    "go.mod",
    ".git",
  },

  capabilities = capabilities,

  settings = {
    gopls = {
      gofumpt = true,
      staticcheck = true,

      analyses = {
        unusedparams = true,
        shadow = true,
        nilness = true,
        unusedwrite = true,
        useany = true,
      },

      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  },
})

-- C / C++ LSP
vim.lsp.config("clangd", {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
  },

  filetypes = {
    "c",
    "cpp",
    "objc",
    "objcpp",
    "h",
    "hpp",
  },

  root_markers = {
    "compile_commands.json",
    "compile_flags.txt",
    ".clangd",
    ".git",
  },

  capabilities = capabilities,
})

-- Bash LSP
vim.lsp.config("bashls", {
  cmd = { "bash-language-server", "start" },

  filetypes = {
    "sh",
    "bash",
  },

  root_markers = {
    ".git",
  },

  capabilities = capabilities,

  settings = {
    bashIde = {
      shellcheckPath = "shellcheck",
      shfmt = {
        path = "shfmt",
      },
    },
  },
})

vim.lsp.enable("gopls")
vim.lsp.enable("clangd")
vim.lsp.enable("bashls")

-- LSP keymaps
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local opts = { buffer = event.buf, silent = true }

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)

    vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

    vim.keymap.set("n", "<leader>f", function()
      vim.lsp.buf.format({ async = true })
    end, opts)
  end,
})

-- Format on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = {
    "*.go",
    "*.c",
    "*.h",
    "*.cpp",
    "*.hpp",
    "*.sh",
    "*.bash",
  },

  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

-- Filetype detection for scripts without file extensions
vim.filetype.add({
  pattern = {
    [".*/bin/.*"] = "sh",
    [".*/scripts/.*"] = "sh",
  },
})

-- Go keymaps
vim.keymap.set("n", "<leader>rr", ":!go run .<CR>", {
  silent = false,
  desc = "Go run",
})

vim.keymap.set("n", "<leader>tt", ":!go test ./...<CR>", {
  silent = false,
  desc = "Go test",
})

vim.keymap.set("n", "<leader>tv", ":!go test -v ./...<CR>", {
  silent = false,
  desc = "Go test verbose",
})

vim.keymap.set("n", "<leader>gb", ":!go build ./...<CR>", {
  silent = false,
  desc = "Go build",
})

-- C keymaps
vim.keymap.set("n", "<leader>cc", ":!cc -Wall -Wextra -std=c17 % -o /tmp/cmain && /tmp/cmain<CR>", {
  silent = false,
  desc = "Compile and run C file",
})

vim.keymap.set("n", "<leader>cb", ":!make<CR>", {
  silent = false,
  desc = "Make build",
})

vim.keymap.set("n", "<leader>ct", ":!make test<CR>", {
  silent = false,
  desc = "Make test",
})

-- Bash keymaps
vim.keymap.set("n", "<leader>sr", ":!bash %<CR>", {
  silent = false,
  desc = "Run shell script",
})

vim.keymap.set("n", "<leader>sc", ":!shellcheck %<CR>", {
  silent = false,
  desc = "ShellCheck script",
})

vim.keymap.set("n", "<leader>sf", ":!shfmt -w %<CR>", {
  silent = false,
  desc = "Format shell script",
})
