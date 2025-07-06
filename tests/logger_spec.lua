local spy = require "luassert.spy"

describe("logger", function()
  local logger
  local options

  before_each(function()
    -- Clear loaded modules
    package.loaded["yadm-git.logger"] = nil
    package.loaded["yadm-git.options"] = nil

    -- Mock options
    options = {
      opts = {
        debug = false
      }
    }
    package.preload["yadm-git.options"] = function()
      return options
    end

    -- Mock vim.notify
    _G.vim = _G.vim or {}
    _G.vim.notify = spy.new(function() end)
    _G.vim.log = {
      levels = {
        DEBUG = 1,
        INFO = 2,
        WARN = 3,
        ERROR = 4
      }
    }

    -- Load the module
    logger = require "yadm-git.logger"
  end)

  after_each(function()
    -- Clean up
    package.preload["yadm-git.options"] = nil
  end)

  describe("log", function()
    it("should not call vim.notify when debug is false", function()
      options.opts.debug = false
      logger.log("test message")
      assert.spy(vim.notify).was_not_called()
    end)

    it("should call vim.notify when debug is true", function()
      options.opts.debug = true
      logger.log("test message")
      assert.spy(vim.notify).was_called_with("[yadm-git] test message", vim.log.levels.INFO)
    end)

    it("should use custom log level when provided", function()
      options.opts.debug = true
      logger.log("test message", vim.log.levels.WARN)
      assert.spy(vim.notify).was_called_with("[yadm-git] test message", vim.log.levels.WARN)
    end)
  end)

  describe("debug", function()
    it("should call log with DEBUG level", function()
      options.opts.debug = true
      logger.debug("debug message")
      assert.spy(vim.notify).was_called_with("[yadm-git] debug message", vim.log.levels.DEBUG)
    end)
  end)

  describe("info", function()
    it("should call log with INFO level", function()
      options.opts.debug = true
      logger.info("info message")
      assert.spy(vim.notify).was_called_with("[yadm-git] info message", vim.log.levels.INFO)
    end)
  end)

  describe("warn", function()
    it("should call log with WARN level", function()
      options.opts.debug = true
      logger.warn("warning message")
      assert.spy(vim.notify).was_called_with("[yadm-git] warning message", vim.log.levels.WARN)
    end)
  end)

  describe("error", function()
    it("should call log with ERROR level", function()
      options.opts.debug = true
      logger.error("error message")
      assert.spy(vim.notify).was_called_with("[yadm-git] error message", vim.log.levels.ERROR)
    end)
  end)
end)