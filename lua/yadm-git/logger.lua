local M = {}

M.log = function(msg, level)
  local opts = require("yadm-git.options").opts
  if opts.debug then
    vim.notify("[yadm-git] " .. msg, level or vim.log.levels.INFO)
  end
end

M.debug = function(msg)
  M.log(msg, vim.log.levels.DEBUG)
end

M.info = function(msg)
  M.log(msg, vim.log.levels.INFO)
end

M.warn = function(msg)
  M.log(msg, vim.log.levels.WARN)
end

M.error = function(msg)
  M.log(msg, vim.log.levels.ERROR)
end

return M
