local M = {
  -- Plugin state
  _state = {
    is_active = false,
    yadm_repo_path = nil,
  },
}

M.reset_state = function()
  M._state.is_active = false
  M._state.yadm_repo_path = nil
end

M.activate = function(repo_path)
  M._state.is_active = true
  M._state.yadm_repo_path = repo_path
end

M.deactivate = function()
  M._state.is_active = false
  M._state.yadm_repo_path = nil
end

M.is_active = function()
  return M._state.is_active
end

M.get_yadm_repo_path = function()
  return M._state.yadm_repo_path
end

M.get_state = function()
  return {
    is_active = M._state.is_active,
    yadm_repo_path = M._state.yadm_repo_path,
  }
end

return M
