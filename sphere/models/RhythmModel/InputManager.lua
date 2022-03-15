local Class			= require("aqua.util.Class")
local Observable	= require("aqua.util.Observable")

local InputManager = Class:new()

InputManager.mode = "external"

InputManager.construct = function(self)
	self.observable = Observable:new()
end

InputManager.setMode = function(self, mode)
	self.mode = mode
end

InputManager.setBindings = function(self, inputBindings)
	self.inputBindings = inputBindings
end

InputManager.send = function(self, event)
	return self.observable:send(event)
end

InputManager.setInputMode = function(self, inputMode)
	self.inputMode = inputMode
	self.inputConfig = self.inputBindings[inputMode]
end

InputManager.getKeyConfig = function(self, event)
	if not event.name:find("^.+pressed$") and not event.name:find("^.+released$") then
		return
	end

	local device = event.name:match("^(.+)pressed$") or event.name:match("^(.+)released$")
	if device == "key" then
		device = "keyboard"
	end

	local state = "press"
	if event.name:find("^.+released$") then
		state = "release"
	end

	local key = tostring(event[2])
	if device == "midi" then
		key = tostring(event[1])
	end

	local inputConfig = self.inputConfig
	return
		inputConfig[state] and
		inputConfig[state][device] and
		inputConfig[state][device][key]
end

InputManager.receive = function(self, event)
	local mode = self.mode

	if event.virtual and mode == "internal" then
		return self:send(event)
	end

	if mode ~= "external" or not self.inputConfig then
		return
	end

	local isPlaying = self.rhythmModel.timeEngine.timer.isPlaying
	if not isPlaying then
		return
	end

	local keyConfig = self:getKeyConfig(event)
	if not keyConfig then
		return
	end

	local timeEngine = self.rhythmModel.timeEngine
	local eventTime = timeEngine.timer:transformTime(event.time)
	eventTime = math.floor(eventTime * 1024) / 1024

	local virtualEvent = {
		virtual = true,
		time = eventTime,
	}

	virtualEvent.name = "keypressed"
	for _, key in ipairs(keyConfig.press) do
		virtualEvent[1] = key
		self:send(virtualEvent)
	end
	virtualEvent.name = "keyreleased"
	for _, key in ipairs(keyConfig.release) do
		virtualEvent[1] = key
		self:send(virtualEvent)
	end
end

return InputManager
