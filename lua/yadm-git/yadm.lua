local M = {}

local logger = require("yadm-git.logger")

function M.is_inside_git_worktree()
  local obj = vim.system({ "git", "rev-parse", "--is-inside-work-tree" }, { stderr = false }):wait()
  if obj.code ~= 0 then
    return false
  end
  return obj.stdout:match("^true") ~= nil
end

function M.is_inside_yadm_worktree()
  local obj = vim.system({ "yadm", "rev-parse", "--is-inside-work-tree" }):wait()
  if obj.code ~= 0 then
    return false
  end
  return obj.stdout:match("^true") ~= nil
end

function M.is_yadm_managed()
  return not M.is_inside_git_worktree() and M.is_inside_yadm_worktree()
end

function M.setup_yadm_env()
  local obj = vim.system({ "yadm", "rev-parse", "--git-dir" }, { stderr = false }):wait()
  if obj.code ~= 0 then
    logger.warn "Could not determine yadm git-dir"
    return
  end

  local gitdir = obj.stdout:match "^%s*(.-)%s*$"
  if not gitdir or gitdir == "" then
    logger.warn "Could not determine yadm git-dir"
    return
  end
  vim.env.GIT_DIR = gitdir
  vim.env.GIT_WORK_TREE = os.getenv "HOME"
end

return M
