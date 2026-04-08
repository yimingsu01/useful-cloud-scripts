-- lua/plugins/python.lua
local python_env = require("config.python_env")

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ty = {
          root_dir = python_env.root_dir,
          before_init = function(_, config)
            python_env.apply_venv(config)
          end,
        },
      },
    },
  },
}
