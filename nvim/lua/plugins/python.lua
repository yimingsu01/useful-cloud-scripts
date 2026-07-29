return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        basedpyright = {
          enabled = true,
          -- basedpyright automatically uses <project root>/.venv when pythonPath is unset.
          root_markers = {
            "pyrightconfig.json",
            "pyproject.toml",
            "setup.py",
            "setup.cfg",
            "requirements.txt",
            "Pipfile",
            ".venv",
            ".git",
          },
          settings = {
            basedpyright = {
              disableOrganizeImports = true,
            },
          },
        },
        -- Keep LazyVim/Mason from installing or enabling Pyright.
        pyright = {
          enabled = false,
        },
      },
    },
  },
}
