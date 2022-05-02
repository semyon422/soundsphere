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
	self.inputState = {}
end

InputManager.setInputState = function(self, device, key, state, keyConfig)
	local s = self.inputState
	s[device] = s[device] or {}
	s[device][key] = s[device][key] or {}

	local info = s[device][key]
	info.state = state
	info.keyConfig = keyConfig
end

InputManager.loadState = function(self)
	local currentTime = self.rhythmModel.timeEngine.currentTime
	for device, a in pairs(self.inputState) do
		for key, info in pairs(a) do
			if info.state ~= info.savedState then
				self:applyKeyConfig(info.keyConfig, currentTime)
			end
		end
	end
end

InputManager.saveState = function(self)
	for device, a in pairs(self.inputState) do
		for key, info in pairs(a) do
			info.savedState = info.state
			info.savedKeyConfig = info.keyConfig
		end
	end
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
		key = event[1]
	end

	local inputConfig = self.inputConfig
	return
		inputConfig[state] and
		inputConfig[state][device] and
		inputConfig[state][device][key], device, key, state
end

local virtualEvent = {virtual = true}
InputManager.applyKeyConfig = function(self, keyConfig, time)
	virtualEvent.time = math.floor(time * 1024) / 1024
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

InputManager.receive = function(self, event)
	local mode = self.mode

	if event.virtual and mode == "internal" then
		return self:send(event)
	end

	if mode ~= "external" or not self.inputConfig then
		return
	end

	local timeEngine = self.rhythmModel.timeEngine
	local isPlaying = timeEngine.timer.isPlaying

	local keyConfig, device, key, state = self:getKeyConfig(event)
	if not keyConfig then return end

	self:setInputState(device, key, state, keyConfig)

	if not isPlaying then return end

	self:applyKeyConfig(keyConfig, timeEngine.timer:transformTime(event.time))
end

return InputManager
