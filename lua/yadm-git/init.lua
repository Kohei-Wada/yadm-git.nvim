local M = {}
local state = require "yadm-git.state"
local logger = require "yadm-git.logger"
local yadm = require "yadm-git.yadm"
local event = require "yadm-git.event"

M.setup = function(user_opts)
  local options = require "yadm-git.options"
  options.setup(user_opts)

  if not yadm.is_yadm_managed() then
    logger.log "Not a YADM managed repository. Skipping setup."
    return
  end

  logger.info "YADM managed repository detected. Setting up environment."
  yadm.setup_yadm_env()
  state.activate(yadm.get_yadm_repo_path())
  event.setup_auto_commands()
end

-- Public API to check if plugin is active
M.is_active = state.is_active

-- Get the yadm repository path if active
M.get_yadm_repo_path = state.get_yadm_repo_path

-- Get current plugin state
M.get_state = state.get_state

return M
