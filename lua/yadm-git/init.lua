local M = {}

M.setup = function(user_opts)
  -- Set up the configuration
  require('yadm-git.options').setup(user_opts)

  local logger = require('yadm-git.logger')
  local yadm = require('yadm-git.yadm')

  -- Check if the current directory is a YADM managed repository
  if not yadm.is_yadm_managed() then
    logger.log('Not a YADM managed repository. Skipping setup.')
    return
  end

  logger.info("YADM managed repository detected. Setting up environment.")
  -- Set up the YADM environment
  yadm.setup_yadm_env()
end

return M
