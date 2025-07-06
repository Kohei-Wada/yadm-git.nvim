local stub = require "luassert.stub"

describe("yadm-git", function()
  local plugin
  local yadm
  local options
  local logger
  local state
  local event

  before_each(function()
    -- Clear loaded modules
    package.loaded["yadm-git"] = nil
    package.loaded["yadm-git.yadm"] = nil
    package.loaded["yadm-git.options"] = nil
    package.loaded["yadm-git.logger"] = nil
    package.loaded["yadm-git.state"] = nil
    package.loaded["yadm-git.event"] = nil

    -- Mock state module
    state = {
      activate = stub.new(function() end),
      is_active = stub.new(function()
        return false
      end),
      get_yadm_repo_path = stub.new(function()
        return nil
      end),
      get_state = stub.new(function()
        return { is_active = false, yadm_repo_path = nil }
      end),
    }
    package.preload["yadm-git.state"] = function()
      return state
    end

    -- Mock logger module
    logger = {
      log = stub.new(function() end),
      info = stub.new(function() end),
    }
    package.preload["yadm-git.logger"] = function()
      return logger
    end

    -- Mock yadm module
    yadm = {
      is_yadm_managed = stub.new(function()
        return false
      end),
      setup_yadm_env = stub.new(function() end),
      get_yadm_repo_path = stub.new(function()
        return nil
      end),
    }
    package.preload["yadm-git.yadm"] = function()
      return yadm
    end

    -- Mock options module
    options = {
      setup = stub.new(function() end),
    }
    package.preload["yadm-git.options"] = function()
      return options
    end

    -- Mock event module
    event = {
      setup_auto_commands = stub.new(function() end),
    }
    package.preload["yadm-git.event"] = function()
      return event
    end

    -- Load the main module
    plugin = require "yadm-git"
  end)

  after_each(function()
    -- Clean up
    package.preload["yadm-git.state"] = nil
    package.preload["yadm-git.logger"] = nil
    package.preload["yadm-git.yadm"] = nil
    package.preload["yadm-git.options"] = nil
    package.preload["yadm-git.event"] = nil
  end)

  describe("setup", function()
    it("activates plugin when in yadm-managed directory", function()
      yadm.is_yadm_managed.returns(true)
      yadm.get_yadm_repo_path.returns "/home/user/.local/share/yadm/repo.git"

      plugin.setup()

      assert.stub(options.setup).was_called()
      assert.stub(yadm.setup_yadm_env).was_called()
      assert.stub(state.activate).was_called_with "/home/user/.local/share/yadm/repo.git"
      assert.stub(event.setup_auto_commands).was_called()
    end)

    it("does not activate when not in yadm-managed directory", function()
      yadm.is_yadm_managed.returns(false)

      plugin.setup()

      assert.stub(options.setup).was_called()
      assert.stub(yadm.setup_yadm_env).was_not_called()
      assert.stub(state.activate).was_not_called()
      assert.stub(event.setup_auto_commands).was_not_called()
    end)

    it("passes user options to options.setup", function()
      local user_opts = { debug = true }
      yadm.is_yadm_managed.returns(false)

      plugin.setup(user_opts)

      assert.stub(options.setup).was_called_with(user_opts)
    end)
  end)

  describe("is_active", function()
    it("delegates to state.is_active", function()
      state.is_active.returns(false)
      assert.is_false(plugin.is_active())
      assert.stub(state.is_active).was_called()

      state.is_active.returns(true)
      assert.is_true(plugin.is_active())
    end)
  end)

  describe("get_yadm_repo_path", function()
    it("delegates to state.get_yadm_repo_path", function()
      state.get_yadm_repo_path.returns(nil)
      assert.is_nil(plugin.get_yadm_repo_path())
      assert.stub(state.get_yadm_repo_path).was_called()

      state.get_yadm_repo_path.returns "/home/user/.yadm/repo.git"
      assert.equals("/home/user/.yadm/repo.git", plugin.get_yadm_repo_path())
    end)
  end)

  describe("get_state", function()
    it("delegates to state.get_state", function()
      local test_state = { is_active = true, yadm_repo_path = "/test/path" }
      state.get_state.returns(test_state)

      local result = plugin.get_state()

      assert.stub(state.get_state).was_called()
      assert.equals(test_state, result)
    end)
  end)
end)
