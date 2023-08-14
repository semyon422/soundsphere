local class = require("class")
local Observable = require("Observable")

local InputManager = class()

InputManager.mode = "external"

function InputManager:new()
	self.observable = Observable()
end

function InputManager:setMode(mode)
	assert(mode == "external" or mode == "internal")
	self.mode = mode
end

function InputManager:send(event)
	return self.observable:send(event)
end

function InputManager:setInputMode(inputMode)
	self.inputMode = inputMode
	self.state = {}
	self.savedState = {}
end

function InputManager:setState(virtualKey, state)
	self.state[virtualKey] = state
end

function InputManager:loadState()
	local currentTime = self.rhythmModel.timeEngine.currentTime
	for virtualKey, state in pairs(self.state) do
		if state ~= self.savedState[virtualKey] then
			self:apply(virtualKey, state, currentTime)
		end
	end
end

function InputManager:saveState()
	for virtualKey, state in pairs(self.state) do
		self.savedState[virtualKey] = state
	end
end

local virtualEvent = {virtual = true}
function InputManager:apply(virtualKey, state, time)
	virtualEvent.time = math.floor(time * 1024) / 1024
	virtualEvent.name = state and "keypressed" or "keyreleased"
	virtualEvent[1] = virtualKey
	self:send(virtualEvent)
end

function InputManager:receive(event)
	if event.virtual and self.mode == "internal" then
		return self:send(event)
	end

	local virtualKey, state = self.rhythmModel.inputModel:transformEvent(self.inputMode, event)
	if not virtualKey then return end

	self:setState(virtualKey, state)

	local timeEngine = self.rhythmModel.timeEngine
	local isPlaying = timeEngine.timer.isPlaying
	if not isPlaying then return end

	self:apply(virtualKey, state, timeEngine.timer:transform(event.time))
end

return InputManager
