local M = {}

function M.root_dir(fname)
  return vim.fs.root(fname, { "pyproject.toml" })
end

function M.cmd_env(root)
  if not root then
    return nil
  end

  local venv = root .. "/.venv"
  if vim.fn.isdirectory(venv) == 0 then
    return nil
  end

  return {
    VIRTUAL_ENV = venv,
    PATH = venv .. "/bin:" .. vim.env.PATH,
  }
end

function M.apply_venv(config)
  local env = M.cmd_env(config.root_dir)
  if not env then
    return
  end

  config.cmd_env = vim.tbl_extend("force", config.cmd_env or {}, env)
end

return M
