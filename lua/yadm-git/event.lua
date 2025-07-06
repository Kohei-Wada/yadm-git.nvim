local M = {}

local state = require "yadm-git.state"
local logger = require "yadm-git.logger"
local yadm = require "yadm-git.yadm"

local function handle_events()
  if not yadm.is_yadm_managed() then
    logger.warn "Directory changed to non-YADM managed directory. Deactivating plugin."
    yadm.clear_yadm_env()
    state.deactivate()
  else
    logger.info "Directory is YADM managed. Updating environment."
    yadm.setup_yadm_env()
    state.activate(yadm.get_yadm_repo_path())
  end
end

M.setup_auto_commands = function()
  vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
    pattern = "*",
    callback = handle_events,
    desc = "Handle directory changes for YADM managed repositories",
  })
end

return M
