return {
  {
    "folke/snacks.nvim",
    opts = {
      explorer = { enabled = false },
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    enabled = false,
  },
  {
    "echasnovski/mini.files",
    lazy = false,
    opts = {
      options = {
        use_as_default_explorer = true,
      },
    },
  },
  {
    "maxmx03/solarized.nvim",
    lazy = false,
    priority = 1000,
    ---@type solarized.config
    opts = {},
    config = function(_, opts)
      vim.o.termguicolors = true
      vim.o.background = "light"
      require("solarized").setup(opts)
      vim.cmd.colorscheme("solarized")
    end,
  },
}
