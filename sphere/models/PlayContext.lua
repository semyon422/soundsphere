local class = require("class")

---@class sphere.PlayContext
---@operator call: sphere.PlayContext
local PlayContext = class()

function PlayContext:new()
	self.const = false
	self.rate = 1
	self.modifiers = {}
end

---@param t table
function PlayContext:load(t)
	self.modifiers = t.modifiers
	self.rate = t.rate
	self.const = t.const
end

---@param t table
function PlayContext:save(t)
	t.modifiers = self.modifiers
	t.rate = self.rate
	t.const = self.const
end

return PlayContext
