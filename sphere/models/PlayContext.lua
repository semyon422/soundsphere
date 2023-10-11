local class = require("class")
local InputMode = require("ncdk.InputMode")

---@class sphere.PlayContext
---@operator call: sphere.PlayContext
local PlayContext = class()

function PlayContext:new()
	self.state = {
		timeRate = 1,
		inputMode = InputMode(),
	}
	self.modifiers = {}
end

---@param inputMode ncdk.InputMode|string
function PlayContext:setInputMode(inputMode)
	self.inputMode = InputMode(inputMode)
end

function PlayContext:reset()
	self.state.timeRate = 1
	self.state.inputMode = InputMode()
end

return PlayContext
