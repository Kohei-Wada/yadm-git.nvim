local M = {}

local logger = require "yadm-git.logger"

-- Resolve the user's home directory.
-- Prefer `vim.fn.expand("~")` over `vim.uv.os_homedir()` or $HOME because on immutable distros
-- (Bazzite, etc.) the folder /home/ is a symlink to /var/home/ which is resolved by Neovim
-- in the functions `vim.fn.fnamemodify()` and `vim.fn.getcwd()` but not when using $HOME
-- or libuv's `os_homedir()`.
-- See issue #19 for more information.
local function get_home()
  return vim.fn.expand "~"
end

-- Check if a .git directory or file exists in current path hierarchy (indicates regular git)
local function has_local_git()
  -- Check for .git directory (regular repos)
  local git_dir = vim.fn.finddir(".git", vim.fn.getcwd() .. ";")
  if git_dir ~= "" then
    return true
  end

  -- Check for .git file (worktrees)
  local git_file = vim.fn.findfile(".git", vim.fn.getcwd() .. ";")
  return git_file ~= ""
end

-- Get yadm repository path if it exists
function M.get_yadm_repo_path()
  local home = get_home()
  if not home then
    logger.warn "Could not determine home directory"
    return nil
  end
  -- Check modern location first (v3+)
  local xdg_data = vim.env.XDG_DATA_HOME or (home .. "/.local/share")
  local modern_path = xdg_data .. "/yadm/repo.git"
  if vim.fn.isdirectory(modern_path) == 1 then
    logger.debug("Found yadm repo at modern location: " .. modern_path)
    return modern_path
  end

  -- Check legacy location
  local legacy_path = home .. "/.yadm/repo.git"
  if vim.fn.isdirectory(legacy_path) == 1 then
    logger.debug("Found yadm repo at legacy location: " .. legacy_path)
    return legacy_path
  end

  return nil
end

-- Check if current directory is under HOME
local function is_under_home()
  local home = get_home()
  if not home then
    return false
  end

  local current_path = vim.fn.fnamemodify(vim.fn.getcwd(), ":p")
  return vim.startswith(current_path, home .. "/")
end

-- Main detection function using filesystem checks only
function M.is_yadm_managed()
  -- If there's a .git directory or file, it's regular git, not yadm
  if has_local_git() then
    logger.debug "Found .git directory or file - not yadm managed"
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

  local home = get_home()
  vim.env.GIT_DIR = yadm_repo
  vim.env.GIT_WORK_TREE = home
  logger.info("Set GIT_DIR=" .. yadm_repo .. " GIT_WORK_TREE=" .. home)
end

function M.clear_yadm_env()
  -- Clear yadm-related environment variables
  vim.env.GIT_DIR = nil
  vim.env.GIT_WORK_TREE = nil
  logger.info "Cleared yadm environment variables"
end

return M
