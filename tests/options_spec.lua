local options = require "yadm-git.options"

describe("options.lua", function()
  local orig_vim

  before_each(function()
    orig_vim = vim
    vim = vim or {}
    vim.tbl_deep_extend = function(mode, defaults, user_opts)
      local result = {}
      for k, v in pairs(defaults) do
        result[k] = v
      end
      for k, v in pairs(user_opts) do
        result[k] = v
      end
      return result
    end
  end)

  after_each(function()
    vim = orig_vim
    options.opts = nil
  end)

  it("defaults has debug=false", function()
    assert.is_false(options.defaults.debug)
  end)

  it("setup merges user_opts into defaults", function()
    options.setup { debug = true }
    assert.is_true(options.opts.debug)
  end)

  it("setup uses defaults if user_opts is nil", function()
    options.setup()
    assert.is_false(options.opts.debug)
  end)

  it("setup uses defaults if user_opts is empty", function()
    options.setup {}
    assert.is_false(options.opts.debug)
  end)

  it("setup merges unknown keys", function()
    options.setup { foo = "bar" }
    assert.equals("bar", options.opts.foo)
    assert.is_false(options.opts.debug)
  end)
end)
