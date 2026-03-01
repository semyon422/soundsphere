local class = require("class")

---@class sphere.Progress
---@operator call: sphere.Progress
local Progress = class()

function Progress:new()
	self.state = 0
	self.count = 0
	self.current = 0
	self.message = ""
	self.stop = false
	---@type string[]
	self.errors = {}
end

function Progress:update(state, count, current, message)
	self.state = state or self.state
	self.count = count or self.count
	self.current = current or self.current
	self.message = message or self.message
end

function Progress:addError(err)
	table.insert(self.errors, tostring(err))
end

function Progress:increment()
	self.current = self.current + 1
end

function Progress:reset(state, count, message)
	self.state = state or 0
	self.count = count or 0
	self.current = 0
	self.message = message or ""
	self.errors = {}
end

return Progress
