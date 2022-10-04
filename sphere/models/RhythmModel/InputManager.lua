local Class			= require("Class")
local Observable	= require("Observable")

local InputManager = Class:new()

InputManager.mode = "external"

InputManager.construct = function(self)
	self.observable = Observable:new()
end

InputManager.setMode = function(self, mode)
	assert(mode == "external" or mode == "internal")
	self.mode = mode
end

InputManager.send = function(self, event)
	return self.observable:send(event)
end

InputManager.setInputMode = function(self, inputMode)
	self.inputMode = inputMode
	self.state = {}
	self.savedState = {}
end

InputManager.setState = function(self, virtualKey, state)
	self.state[virtualKey] = state
end

InputManager.loadState = function(self)
	local currentTime = self.rhythmModel.timeEngine.currentTime
	for virtualKey, state in pairs(self.state) do
		if state ~= self.savedState[virtualKey] then
			self:apply(virtualKey, state, currentTime)
		end
	end
end

InputManager.saveState = function(self)
	for virtualKey, state in pairs(self.state) do
		self.savedState[virtualKey] = state
	end
end

local virtualEvent = {virtual = true}
InputManager.apply = function(self, virtualKey, state, time)
	virtualEvent.time = math.floor(time * 1024) / 1024
	virtualEvent.name = state and "keypressed" or "keyreleased"
	virtualEvent[1] = virtualKey
	self:send(virtualEvent)
end

InputManager.receive = function(self, event)
	if event.virtual and self.mode == "internal" then
		return self:send(event)
	end

	local virtualKey, state = self.rhythmModel.game.inputModel:transformEvent(self.inputMode, event)
	if not virtualKey then return end

	self:setState(virtualKey, state)

	local timeEngine = self.rhythmModel.timeEngine
	local isPlaying = timeEngine.timer.isPlaying
	if not isPlaying then return end

	self:apply(virtualKey, state, timeEngine.timer:transformTime(event.time))
end

return InputManager
