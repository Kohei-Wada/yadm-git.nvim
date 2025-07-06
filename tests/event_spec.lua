local spy = require "luassert.spy"
local match = require "luassert.match"

describe("event", function()
  local event
  local state
  local logger
  local yadm

  before_each(function()
    -- Clear loaded modules
    package.loaded["yadm-git.event"] = nil
    package.loaded["yadm-git.state"] = nil
    package.loaded["yadm-git.logger"] = nil
    package.loaded["yadm-git.yadm"] = nil

    -- Mock dependencies
    state = {
      activate = function() end,
      deactivate = function() end,
    }
    state.activate = spy.new(state.activate)
    state.deactivate = spy.new(state.deactivate)
    package.preload["yadm-git.state"] = function()
      return state
    end

    logger = {
      info = function() end,
      warn = function() end,
    }
    logger.info = spy.new(logger.info)
    logger.warn = spy.new(logger.warn)
    package.preload["yadm-git.logger"] = function()
      return logger
    end

    yadm = {
      is_yadm_managed = function()
        return false
      end,
      clear_yadm_env = function() end,
      setup_yadm_env = function() end,
      get_yadm_repo_path = function()
        return "/test/yadm/repo.git"
      end,
    }
    yadm.is_yadm_managed = spy.new(yadm.is_yadm_managed)
    yadm.clear_yadm_env = spy.new(yadm.clear_yadm_env)
    yadm.setup_yadm_env = spy.new(yadm.setup_yadm_env)
    yadm.get_yadm_repo_path = spy.new(yadm.get_yadm_repo_path)
    package.preload["yadm-git.yadm"] = function()
      return yadm
    end

    -- Mock vim.api.nvim_create_autocmd
    _G.vim = _G.vim or {}
    _G.vim.api = _G.vim.api or {}
    _G.vim.api.nvim_create_autocmd = spy.new(function() end)

    -- Load the module
    event = require "yadm-git.event"
  end)

  after_each(function()
    -- Clean up
    package.preload["yadm-git.state"] = nil
    package.preload["yadm-git.logger"] = nil
    package.preload["yadm-git.yadm"] = nil
  end)

  describe("setup_auto_commands", function()
    it("should create VimEnter and DirChanged autocmd", function()
      event.setup_auto_commands()

      assert.spy(vim.api.nvim_create_autocmd).was_called(1)
      assert.spy(vim.api.nvim_create_autocmd).was_called_with({"VimEnter", "DirChanged"}, match.is_table())

      local args = vim.api.nvim_create_autocmd.calls[1].vals[2]
      assert.equals("*", args.pattern)
      assert.equals("Handle directory changes for YADM managed repositories", args.desc)
      assert.is_function(args.callback)
    end)
  end)

  describe("DirChanged callback", function()
    local callback

    before_each(function()
      event.setup_auto_commands()
      local args = vim.api.nvim_create_autocmd.calls[1].vals[2]
      callback = args.callback
    end)

    it("should deactivate when directory is not YADM managed", function()
      yadm.is_yadm_managed = spy.new(function()
        return false
      end)
      yadm.clear_yadm_env = spy.new(yadm.clear_yadm_env)
      state.deactivate = spy.new(state.deactivate)

      callback()

      assert.spy(yadm.is_yadm_managed).was_called(1)
      assert.spy(logger.warn).was_called_with "Directory changed to non-YADM managed directory. Deactivating plugin."
      assert.spy(yadm.clear_yadm_env).was_called(1)
      assert.spy(state.deactivate).was_called(1)

      assert.spy(yadm.setup_yadm_env).was_not_called()
      assert.spy(state.activate).was_not_called()
    end)

    it("should activate when directory is YADM managed", function()
      yadm.is_yadm_managed = spy.new(function()
        return true
      end)
      yadm.setup_yadm_env = spy.new(yadm.setup_yadm_env)
      state.activate = spy.new(state.activate)

      callback()

      assert.spy(yadm.is_yadm_managed).was_called(1)
      assert.spy(logger.info).was_called_with "Directory is YADM managed. Updating environment."
      assert.spy(yadm.setup_yadm_env).was_called(1)
      assert.spy(state.activate).was_called_with "/test/yadm/repo.git"

      assert.spy(yadm.clear_yadm_env).was_not_called()
      assert.spy(state.deactivate).was_not_called()
    end)
  end)
end)
