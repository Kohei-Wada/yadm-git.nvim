local M = {}

M.defaults = {
  debug = false,
}

M.setup = function(user_opts)
  user_opts = user_opts or {}
  M.opts = vim.tbl_deep_extend("force", M.defaults, user_opts)
end

return M
