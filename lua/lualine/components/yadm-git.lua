local component = require("lualine.component"):extend()
local yadm = require "yadm-git"

local function yadm_git_status()
  return yadm.is_active() and "🏠 dotfiles" or ""
end

---Initialize component
---@override
function component:init()
  component.super.init(self)
  return yadm_git_status()
end

-- Update the component status
---@override
function component:update_status()
  component.super.update_status(self)
  return yadm_git_status()
end

return component
