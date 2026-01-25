-- lua/plugins/python.lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          settings = {
            python = {
              analysis = {
                -- This is the "secret sauce" to make it behave like Basedpyright
                typeCheckingMode = "basic",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "workspace", -- Checks the whole project, not just open files
                reportUnusedImport = "none",
                reportUnusedVariable = "none",
              },
              exclude = {
                "**/node_modules",
                "**/__pycache__",
                "**/.venv",
                "**/venv",
                "**/env",
                "**/.git",
                "**/logs",
                "**/constraint_verifier/output"
              },
            },
          },
        },
      },
    },
  },
}
