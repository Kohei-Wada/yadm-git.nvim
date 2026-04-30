local M = {}

M.log = function(msg, level)
  local opts = require("yadm-git.options").opts
  level = level or vim.log.levels.INFO
  if opts.debug or level >= vim.log.levels.WARN then
    vim.notify("[yadm-git] " .. msg, level)
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
