local M = {
  -- Plugin state
  _state = {
    is_active = false,
    yadm_repo_path = nil,
  },
}

M.setup = function(user_opts)
  -- Set up the configuration
  require("yadm-git.options").setup(user_opts)

  local logger = require "yadm-git.logger"
  local yadm = require "yadm-git.yadm"

  -- Reset state
  M._state.is_active = false
  M._state.yadm_repo_path = nil

  -- Check if the current directory is a YADM managed repository
  if not yadm.is_yadm_managed() then
    logger.log "Not a YADM managed repository. Skipping setup."
    return
  end

  logger.info "YADM managed repository detected. Setting up environment."
  yadm.setup_yadm_env()

  vim.api.nvim_create_autocmd("DirChanged", {
    callback = function()
      if not yadm.is_yadm_managed() then
        logger.warn "Directory changed to non-YADM managed directory. Deactivating plugin."
        yadm.clear_yadm_env()
        M._state.is_active = false
        M._state.yadm_repo_path = nil
      else
        logger.info "Directory is still YADM managed. Updating environment."
        yadm.setup_yadm_env()
        M._state.is_active = true
        M._state.yadm_repo_path = yadm.get_yadm_repo_path()
      end
    end,
  })

  -- Update state
  M._state.is_active = true
  M._state.yadm_repo_path = yadm.get_yadm_repo_path()
end

-- Public API to check if plugin is active
M.is_active = function()
  return M._state.is_active
end

-- Get the yadm repository path if active
M.get_yadm_repo_path = function()
  return M._state.yadm_repo_path
end

-- Get current plugin state
M.get_state = function()
  return vim.deepcopy(M._state)
end

return M
