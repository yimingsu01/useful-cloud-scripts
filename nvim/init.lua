-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
local python_env = require("config.python_env")

vim.lsp.config("ruff", {
  root_dir = python_env.root_dir,
  before_init = function(_, config)
    python_env.apply_venv(config)
  end,
})

vim.lsp.enable("ruff")
vim.api.nvim_set_keymap("t", "<ESC>", "<C-\\><C-n>", { noremap = true })
