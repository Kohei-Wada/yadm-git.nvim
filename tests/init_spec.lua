local plugin = require "yadm-git"
local yadm = require "yadm-git.yadm"
local options = require "yadm-git.options"
local stub = require "luassert.stub"

describe("yadm-git", function()
  local orig_is_yadm_managed
  local orig_setup_yadm_env
  local orig_get_yadm_repo_path
  local orig_options_setup
  local logger

  before_each(function()
    logger = require "yadm-git.logger"
    stub(logger, "log")
    stub(logger, "info")

    -- Store original functions
    orig_is_yadm_managed = yadm.is_yadm_managed
    orig_setup_yadm_env = yadm.setup_yadm_env
    orig_get_yadm_repo_path = yadm.get_yadm_repo_path
    orig_options_setup = options.setup

    -- Stub functions
    yadm.is_yadm_managed = stub(yadm, "is_yadm_managed")
    yadm.setup_yadm_env = stub(yadm, "setup_yadm_env")
    yadm.get_yadm_repo_path = stub(yadm, "get_yadm_repo_path")
    options.setup = stub(options, "setup")

    -- Reset state
    plugin._state.is_active = false
    plugin._state.yadm_repo_path = nil
  end)

  after_each(function()
    -- Restore original functions
    yadm.is_yadm_managed = orig_is_yadm_managed
    yadm.setup_yadm_env = orig_setup_yadm_env
    yadm.get_yadm_repo_path = orig_get_yadm_repo_path
    options.setup = orig_options_setup

    logger.log:revert()
    logger.info:revert()
  end)

  describe("setup", function()
    it("activates plugin when in yadm-managed directory", function()
      yadm.is_yadm_managed.returns(true)
      yadm.get_yadm_repo_path.returns "/home/user/.local/share/yadm/repo.git"

      plugin.setup()

      assert.stub(options.setup).was_called()
      assert.stub(yadm.setup_yadm_env).was_called()
      assert.is_true(plugin._state.is_active)
      assert.equals("/home/user/.local/share/yadm/repo.git", plugin._state.yadm_repo_path)
    end)

    it("does not activate when not in yadm-managed directory", function()
      yadm.is_yadm_managed.returns(false)

      plugin.setup()

      assert.stub(options.setup).was_called()
      assert.stub(yadm.setup_yadm_env).was_not_called()
      assert.is_false(plugin._state.is_active)
      assert.is_nil(plugin._state.yadm_repo_path)
    end)

    it("passes user options to options.setup", function()
      local user_opts = { debug = true }
      yadm.is_yadm_managed.returns(false)

      plugin.setup(user_opts)

      assert.stub(options.setup).was_called_with(user_opts)
    end)
  end)

  describe("is_active", function()
    it("returns false when plugin is not active", function()
      plugin._state.is_active = false
      assert.is_false(plugin.is_active())
    end)

    it("returns true when plugin is active", function()
      plugin._state.is_active = true
      assert.is_true(plugin.is_active())
    end)
  end)

  describe("get_yadm_repo_path", function()
    it("returns nil when plugin is not active", function()
      plugin._state.yadm_repo_path = nil
      assert.is_nil(plugin.get_yadm_repo_path())
    end)

    it("returns repo path when plugin is active", function()
      plugin._state.yadm_repo_path = "/home/user/.yadm/repo.git"
      assert.equals("/home/user/.yadm/repo.git", plugin.get_yadm_repo_path())
    end)
  end)

  describe("get_state", function()
    it("returns a copy of the current state", function()
      plugin._state.is_active = true
      plugin._state.yadm_repo_path = "/test/path"

      local state = plugin.get_state()

      assert.equals(true, state.is_active)
      assert.equals("/test/path", state.yadm_repo_path)

      -- Verify it's a copy, not a reference
      state.is_active = false
      assert.equals(true, plugin._state.is_active)
    end)
  end)
end)
