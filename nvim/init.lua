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
vim.opt.undofile = true
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged", "FocusLost", "BufLeave" }, {
  pattern = "*",
  command = "silent! update",
})
vim.cmd.colorscheme('solarized')

-- Track the currently running `make` job, if any.
local make_job = nil

-- Track the last buffer change we already built for.
local last_made_tick = {}

-- Create an augroup so re-sourcing your config does not duplicate the autocmd.
local group = vim.api.nvim_create_augroup("TexAutoMake", { clear = true })

vim.api.nvim_create_autocmd("InsertLeave", {
  group = group,
  pattern = "*.tex",
  callback = function(args)
    -- Do nothing if `make` is not available on this system.
    if vim.fn.executable("make") ~= 1 then
      return
    end

    local bufnr = args.buf
    local tick = vim.b[bufnr].changedtick

    -- If this buffer has not changed since the last time we ran `make`,
    -- do nothing.
    if last_made_tick[bufnr] == tick then
      return
    end

    -- If a previous `make` job is still running, do not start another one.
    if make_job and vim.fn.jobwait({ make_job }, 0)[1] == -1 then
      return
    end

    -- Remember that we already built this exact buffer state.
    last_made_tick[bufnr] = tick

    -- Start `make` in Neovim's current working directory.
    -- Using a list avoids shell parsing.
    make_job = vim.fn.jobstart({ "make" })
  end,
})
