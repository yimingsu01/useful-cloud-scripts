-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
vim.lsp.config("ruff", {
  init_options = {
    settings = {
      args = { "--config ~/.ruff.toml" },
    },
  },
})

vim.lsp.enable("ruff")
vim.api.nvim_set_keymap("t", "<ESC>", "<C-\\><C-n>", { noremap = true })
