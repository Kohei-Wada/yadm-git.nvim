local M = {}
local state = require "yadm-git.state"
local event = require "yadm-git.event"

M.setup = function(user_opts)
  local options = require "yadm-git.options"
  options.setup(user_opts)
  event.setup_auto_commands()
end

-- Public API to check if plugin is active
M.is_active = state.is_active

-- Get the yadm repository path if active
M.get_yadm_repo_path = state.get_yadm_repo_path

-- Get current plugin state
M.get_state = state.get_state

return M
