local M = {}

local logger = require "yadm-git.logger"

-- Check if a .git directory exists in current path hierarchy (indicates regular git)
local function has_local_git_dir()
  local git_path = vim.fn.finddir(".git", vim.fn.getcwd() .. ";")
  return git_path ~= ""
end

-- Get yadm repository path if it exists
function M.get_yadm_repo_path()
  if not vim.env.HOME then
    logger.warn "HOME environment variable is not set"
    return nil
  end
  -- Check modern location first (v3+)
  local xdg_data = vim.env.XDG_DATA_HOME or (vim.env.HOME .. "/.local/share")
  local modern_path = xdg_data .. "/yadm/repo.git"
  if vim.fn.isdirectory(modern_path) == 1 then
    logger.debug("Found yadm repo at modern location: " .. modern_path)
    return modern_path
  end

  -- Check legacy location
  local legacy_path = vim.env.HOME .. "/.yadm/repo.git"
  if vim.fn.isdirectory(legacy_path) == 1 then
    logger.debug("Found yadm repo at legacy location: " .. legacy_path)
    return legacy_path
  end

  return nil
end

-- Check if current directory is under HOME
local function is_under_home()
  local home = vim.env.HOME
  if not home then
    return false
  end

  local current_path = vim.fn.fnamemodify(vim.fn.getcwd(), ":p")
  return vim.startswith(current_path, home .. "/")
end

-- Main detection function using filesystem checks only
function M.is_yadm_managed()
  -- If there's a .git directory, it's regular git, not yadm
  if has_local_git_dir() then
    logger.debug "Found .git directory - not yadm managed"
    return false
  end

  -- Check if yadm repository exists
  local yadm_repo = M.get_yadm_repo_path()
  if not yadm_repo then
    logger.debug "No yadm repository found"
    return false
  end

  -- Check if current directory is under HOME (yadm's work tree)
  if not is_under_home() then
    logger.debug "Not under HOME directory - not yadm managed"
    return false
  end

  logger.debug "Directory is yadm managed"
  return true
end

-- Setup yadm environment variables
function M.setup_yadm_env()
  local yadm_repo = M.get_yadm_repo_path()
  if not yadm_repo then
    logger.warn "Could not find yadm repository"
    return
  end

  vim.env.GIT_DIR = yadm_repo
  vim.env.GIT_WORK_TREE = vim.env.HOME
  logger.info("Set GIT_DIR=" .. yadm_repo .. " GIT_WORK_TREE=" .. vim.env.HOME)
end

function M.clear_yadm_env()
  -- Clear yadm-related environment variables
  vim.env.GIT_DIR = nil
  vim.env.GIT_WORK_TREE = nil
  logger.info "Cleared yadm environment variables"
end

-- Keep these for backwards compatibility with tests
function M.is_inside_git_worktree()
  return has_local_git_dir()
end

function M.is_inside_yadm_worktree()
  local yadm_repo = M.get_yadm_repo_path()
  return yadm_repo ~= nil and is_under_home()
end

return M
