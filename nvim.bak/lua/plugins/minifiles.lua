return {
  {
    "folke/snacks.nvim",
    opts = {
      explorer = { enabled = false },
    }
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
}
