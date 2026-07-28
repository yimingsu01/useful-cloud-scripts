return {
  {
    "saghen/blink.cmp",
    opts = {
      enabled = function()
        return not vim.tbl_contains({ "markdown", "tex", "plaintex", "text" }, vim.bo.filetype)
      end,
    },
  },
}
