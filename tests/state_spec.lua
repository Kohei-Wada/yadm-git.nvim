describe("state", function()
  local state

  before_each(function()
    state = require "yadm-git.state"
    state.reset_state()
  end)

  describe("reset_state", function()
    it("should reset all state to initial values", function()
      state.activate "/test/path"
      assert.is_true(state.is_active())
      assert.equals("/test/path", state.get_yadm_repo_path())

      state.reset_state()
      assert.is_false(state.is_active())
      assert.is_nil(state.get_yadm_repo_path())
    end)
  end)

  describe("activate", function()
    it("should set active state and repo path", function()
      state.activate "/home/user/.local/share/yadm/repo.git"
      assert.is_true(state.is_active())
      assert.equals("/home/user/.local/share/yadm/repo.git", state.get_yadm_repo_path())
    end)
  end)

  describe("deactivate", function()
    it("should clear active state and repo path", function()
      state.activate "/test/path"
      assert.is_true(state.is_active())

      state.deactivate()
      assert.is_false(state.is_active())
      assert.is_nil(state.get_yadm_repo_path())
    end)
  end)

  describe("is_active", function()
    it("should return false initially", function()
      assert.is_false(state.is_active())
    end)

    it("should return true after activation", function()
      state.activate "/test/path"
      assert.is_true(state.is_active())
    end)

    it("should return false after deactivation", function()
      state.activate "/test/path"
      state.deactivate()
      assert.is_false(state.is_active())
    end)
  end)

  describe("get_yadm_repo_path", function()
    it("should return nil initially", function()
      assert.is_nil(state.get_yadm_repo_path())
    end)

    it("should return repo path after activation", function()
      state.activate "/test/repo.git"
      assert.equals("/test/repo.git", state.get_yadm_repo_path())
    end)

    it("should return nil after deactivation", function()
      state.activate "/test/repo.git"
      state.deactivate()
      assert.is_nil(state.get_yadm_repo_path())
    end)
  end)
end)
