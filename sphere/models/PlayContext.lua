local class = require("class")

---@class sphere.PlayContext
---@operator call: sphere.PlayContext
local PlayContext = class()

---@param t table
function PlayContext:load(t)
	self.modifiers = t.modifiers
	self.rate = t.rate
	self.const = t.const
	self.timings = t.timings
end

---@param t table
function PlayContext:save(t)
	t.modifiers = self.modifiers
	t.rate = self.rate
	t.const = self.const
	t.timings = self.timings
end

return PlayContext
