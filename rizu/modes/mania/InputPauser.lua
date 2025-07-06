local class = require("class")

---@class rizu.InputPauser
---@operator call: rizu.InputPauser
local InputPauser = class()

function InputPauser:new()
	---@type {[ncdk2.Column]: boolean}
	self.states = {}
	---@type {[ncdk2.Column]: boolean}
	self.saved_states = {}
end

---@param key ncdk2.Column
---@param state boolean
function InputPauser:setState(key, state)
	self.states[key] = state
end

function InputPauser:resume()
	for key, state in pairs(self.states) do
		if state ~= self.savedState[key] then
			self:apply(key, state, currentTime)
		end
	end
end

function InputPauser:pause()
	for key, state in pairs(self.states) do
		self.saved_states[key] = state
	end
end

---@param event rizu.VirtualInputEvent
function InputPauser:receive(event)
	
end

return InputPauser
