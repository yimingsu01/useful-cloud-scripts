return {
  {
    "lervag/vimtex",
    init = function()
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_compiler_latexmk = { continuous = 1 }

      local group = vim.api.nvim_create_augroup("user_vimtex_compile", { clear = true })
      vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = "VimtexEventInitPost",
        desc = "Start continuous LaTeX compilation",
        command = "VimtexCompile!",
      })
    end,
  },
}
