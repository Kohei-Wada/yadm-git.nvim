local yadm = require "yadm-git.yadm"
local stub = require "luassert.stub"

describe("yadm-git.yadm", function()
  local orig_vim_system
  local orig_vim_env
  local orig_os_getenv
  local logger

  before_each(function()
    orig_vim_system = vim.system
    orig_vim_env = vim.env
    orig_os_getenv = os.getenv
    logger = require "yadm-git.logger"
    stub(logger, "warn")
    vim.env = {}
  end)

  after_each(function()
    vim.system = orig_vim_system
    vim.env = orig_vim_env
    os.getenv = orig_os_getenv
    logger.warn:revert()
  end)

  describe("is_inside_git_worktree", function()
    it("returns true when git returns true", function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.system = function()
        return {
          wait = function()
            return { code = 0, stdout = "true\n" }
          end,
        }
      end
      assert.is_true(yadm.is_inside_git_worktree())
    end)

    it("returns false when git returns false", function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.system = function()
        return {
          wait = function()
            return { code = 0, stdout = "false\n" }
          end,
        }
      end
      assert.is_false(yadm.is_inside_git_worktree())
    end)

    it("returns false when git fails", function()
      vim.system = function()
        return {
          wait = function()
            return { code = 1, stdout = "" }
          end,
        }
      end
      assert.is_false(yadm.is_inside_git_worktree())
    end)
  end)

  describe("is_inside_yadm_worktree", function()
    it("returns true when yadm returns true", function()
      vim.system = function()
        return {
          wait = function()
            return { code = 0, stdout = "true\n" }
          end,
        }
      end
      assert.is_true(yadm.is_inside_yadm_worktree())
    end)

    it("returns false when yadm returns false", function()
      vim.system = function()
        return {
          wait = function()
            return { code = 0, stdout = "false\n" }
          end,
        }
      end
      assert.is_false(yadm.is_inside_yadm_worktree())
    end)

    it("returns false when yadm fails", function()
      vim.system = function()
        return {
          wait = function()
            return { code = 1, stdout = "" }
          end,
        }
      end
      assert.is_false(yadm.is_inside_yadm_worktree())
    end)
  end)

  describe("is_yadm_managed", function()
    it("returns true when not in git but in yadm", function()
      stub(yadm, "is_inside_git_worktree").returns(false)
      stub(yadm, "is_inside_yadm_worktree").returns(true)
      assert.is_true(yadm.is_yadm_managed())
      yadm.is_inside_git_worktree:revert()
      yadm.is_inside_yadm_worktree:revert()
    end)

    it("returns false when in git", function()
      stub(yadm, "is_inside_git_worktree").returns(true)
      stub(yadm, "is_inside_yadm_worktree").returns(true)
      assert.is_false(yadm.is_yadm_managed())
      yadm.is_inside_git_worktree:revert()
      yadm.is_inside_yadm_worktree:revert()
    end)

    it("returns false when not in yadm", function()
      stub(yadm, "is_inside_git_worktree").returns(false)
      stub(yadm, "is_inside_yadm_worktree").returns(false)
      assert.is_false(yadm.is_yadm_managed())
      yadm.is_inside_git_worktree:revert()
      yadm.is_inside_yadm_worktree:revert()
    end)
  end)

  describe("setup_yadm_env", function()
    it("sets GIT_DIR and GIT_WORK_TREE when yadm returns path", function()
      vim.system = function()
        return {
          wait = function()
            return { code = 0, stdout = " /tmp/yadm.git \n" }
          end,
        }
      end
      os.getenv = function(var)
        if var == "HOME" then
          return "/home/testuser"
        end
      end
      yadm.setup_yadm_env()
      assert.equals("/tmp/yadm.git", vim.env.GIT_DIR)
      assert.equals("/home/testuser", vim.env.GIT_WORK_TREE)
    end)

    it("warns and returns if yadm fails", function()
      vim.system = function()
        return {
          wait = function()
            return { code = 1, stdout = "" }
          end,
        }
      end
      yadm.setup_yadm_env()
      assert.stub(logger.warn).was_called_with "Could not determine yadm git-dir"
    end)

    it("warns and returns if yadm returns empty path", function()
      vim.system = function()
        return {
          wait = function()
            return { code = 0, stdout = "\n" }
          end,
        }
      end
      yadm.setup_yadm_env()
      assert.stub(logger.warn).was_called_with "Could not determine yadm git-dir"
    end)
  end)
end)
