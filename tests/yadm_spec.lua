local yadm = require "yadm-git.yadm"
local stub = require "luassert.stub"

describe("yadm-git.yadm", function()
  local orig_vim_fn
  local orig_vim_env
  local logger

  before_each(function()
    orig_vim_fn = vim.fn
    orig_vim_env = vim.env
    logger = require "yadm-git.logger"
    stub(logger, "warn")
    stub(logger, "info")
    stub(logger, "debug")

    -- Set up mock environment
    vim.env = {
      HOME = "/home/testuser",
      XDG_DATA_HOME = nil, -- Use default
    }

    -- Mock vim.fn functions
    vim.fn = {
      finddir = stub(vim.fn, "finddir"),
      isdirectory = stub(vim.fn, "isdirectory"),
      getcwd = stub(vim.fn, "getcwd"),
      fnamemodify = stub(vim.fn, "fnamemodify"),
    }
  end)

  after_each(function()
    vim.fn = orig_vim_fn
    vim.env = orig_vim_env
    logger.warn:revert()
    logger.info:revert()
    logger.debug:revert()
  end)

  describe("is_inside_git_worktree", function()
    it("returns true when .git directory exists", function()
      vim.fn.getcwd.returns "/some/path"
      vim.fn.finddir.on_call_with(".git", "/some/path;").returns "/some/path/.git"
      assert.is_true(yadm.is_inside_git_worktree())
    end)

    it("returns false when .git directory does not exist", function()
      vim.fn.getcwd.returns "/some/path"
      vim.fn.finddir.on_call_with(".git", "/some/path;").returns ""
      assert.is_false(yadm.is_inside_git_worktree())
    end)
  end)

  describe("is_inside_yadm_worktree", function()
    it("returns true when yadm repo exists and under HOME", function()
      vim.fn.isdirectory.on_call_with("/home/testuser/.local/share/yadm/repo.git").returns(1)
      vim.fn.getcwd.returns "/home/testuser/Documents"
      vim.fn.fnamemodify.returns "/home/testuser/Documents/"

      assert.is_true(yadm.is_inside_yadm_worktree())
    end)

    it("returns true when legacy yadm repo exists and under HOME", function()
      vim.fn.isdirectory.on_call_with("/home/testuser/.local/share/yadm/repo.git").returns(0)
      vim.fn.isdirectory.on_call_with("/home/testuser/.yadm/repo.git").returns(1)
      vim.fn.getcwd.returns "/home/testuser/.config"
      vim.fn.fnamemodify.returns "/home/testuser/.config/"

      assert.is_true(yadm.is_inside_yadm_worktree())
    end)

    it("returns false when no yadm repo exists", function()
      vim.fn.isdirectory.returns(0)
      assert.is_false(yadm.is_inside_yadm_worktree())
    end)

    it("returns false when not under HOME", function()
      vim.fn.isdirectory.on_call_with("/home/testuser/.local/share/yadm/repo.git").returns(1)
      vim.fn.getcwd.returns "/tmp/some/path"
      vim.fn.fnamemodify.returns "/tmp/some/path/"

      assert.is_false(yadm.is_inside_yadm_worktree())
    end)
  end)

  describe("is_yadm_managed", function()
    it("returns true when not in git but has yadm repo and under HOME", function()
      -- No .git directory
      vim.fn.getcwd.returns "/home/testuser/.config/nvim"
      vim.fn.finddir.on_call_with(".git", "/home/testuser/.config/nvim;").returns ""
      -- Has yadm repo
      vim.fn.isdirectory.on_call_with("/home/testuser/.local/share/yadm/repo.git").returns(1)
      -- Under HOME
      vim.fn.fnamemodify.returns "/home/testuser/.config/nvim/"

      assert.is_true(yadm.is_yadm_managed())
    end)

    it("returns false when in git repository", function()
      -- Has .git directory
      vim.fn.getcwd.returns "/some/project"
      vim.fn.finddir.on_call_with(".git", "/some/project;").returns "/some/project/.git"

      assert.is_false(yadm.is_yadm_managed())
    end)

    it("returns false when no yadm repo exists", function()
      -- No .git directory
      vim.fn.getcwd.returns "/home/testuser/.config"
      vim.fn.finddir.on_call_with(".git", "/home/testuser/.config;").returns ""
      -- No yadm repo
      vim.fn.isdirectory.returns(0)

      assert.is_false(yadm.is_yadm_managed())
    end)

    it("returns false when not under HOME", function()
      -- No .git directory
      vim.fn.getcwd.returns "/tmp/test"
      vim.fn.finddir.on_call_with(".git", "/tmp/test;").returns ""
      -- Has yadm repo
      vim.fn.isdirectory.on_call_with("/home/testuser/.local/share/yadm/repo.git").returns(1)
      -- Not under HOME
      vim.fn.fnamemodify.returns "/tmp/test/"

      assert.is_false(yadm.is_yadm_managed())
    end)
  end)

  describe("setup_yadm_env", function()
    it("sets GIT_DIR and GIT_WORK_TREE when modern yadm repo exists", function()
      vim.fn.isdirectory.on_call_with("/home/testuser/.local/share/yadm/repo.git").returns(1)

      yadm.setup_yadm_env()

      assert.equals("/home/testuser/.local/share/yadm/repo.git", vim.env.GIT_DIR)
      assert.equals("/home/testuser", vim.env.GIT_WORK_TREE)
    end)

    it("sets GIT_DIR and GIT_WORK_TREE when legacy yadm repo exists", function()
      vim.fn.isdirectory.on_call_with("/home/testuser/.local/share/yadm/repo.git").returns(0)
      vim.fn.isdirectory.on_call_with("/home/testuser/.yadm/repo.git").returns(1)

      yadm.setup_yadm_env()

      assert.equals("/home/testuser/.yadm/repo.git", vim.env.GIT_DIR)
      assert.equals("/home/testuser", vim.env.GIT_WORK_TREE)
    end)

    it("respects XDG_DATA_HOME when set", function()
      vim.env.XDG_DATA_HOME = "/custom/data"
      vim.fn.isdirectory.on_call_with("/custom/data/yadm/repo.git").returns(1)

      yadm.setup_yadm_env()

      assert.equals("/custom/data/yadm/repo.git", vim.env.GIT_DIR)
      assert.equals("/home/testuser", vim.env.GIT_WORK_TREE)
    end)

    it("warns if no yadm repo found", function()
      vim.fn.isdirectory.returns(0)

      yadm.setup_yadm_env()

      assert.stub(logger.warn).was_called_with "Could not find yadm repository"
      assert.is_nil(vim.env.GIT_DIR)
      assert.is_nil(vim.env.GIT_WORK_TREE)
    end)
  end)
end)
