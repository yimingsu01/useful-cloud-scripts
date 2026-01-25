return {
  {
    "folke/snacks.nvim",
    opts = {
      options = {
        use_as_default_explorer = true,
      },
      explorer = { enabled = true },
      picker = { hidden = true, ignored = true },
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    enabled = false,
  },
  {
    "nvim-mini/mini.files",
    lazy = false,
    opts = {
      options = {
        use_as_default_explorer = false,
      },
    },
  },
}
