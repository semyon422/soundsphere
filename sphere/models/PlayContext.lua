local class = require("class")
local InputMode = require("ncdk.InputMode")

local PlayContext = class()

---@param modifierModel sphere.ModifierModel
function PlayContext:new(modifierModel)
	self.state = {
		timeRate = 1,
		inputMode = InputMode(),
	}
	self.modifierModel = modifierModel
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
