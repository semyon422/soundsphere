local Class			= require("aqua.util.Class")
local Observable	= require("aqua.util.Observable")
local json			= require("json")

local InputManager = Class:new()

InputManager.path = "userdata/input.json"

InputManager.init = function(self)
	self.observable = Observable:new()
end

InputManager.send = function(self, event)
	return self.observable:send(event)
end

InputManager.read = function(self)
	self.data = {}
	if love.filesystem.exists(self.path) then
		local file = io.open(self.path, "r")
		self.data = json.decode(file:read("*all"))
		file:close()
	end
end

InputManager.write = function(self)
	local file = io.open(self.path, "w")
	file:write(json.encode(self.data))
	return file:close()
end

InputManager.setKeysFromInputStats = function(self, inputStats)
	local inputMode = self.inputMode
	for virtualKey, data in pairs(inputStats) do
		print(virtualKey)
		local topKey
		local topKeyCount
		for key, count in pairs(data) do
			print(key, count)
			if not topKey or count > topKeyCount then
				topKey = key
				topKeyCount = count
			end
		end
		self:setKey(inputMode, virtualKey, topKey)
	end
end

InputManager.setKey = function(self, inputMode, virtualKey, key)
	local data = self.data
	data[inputMode] = data[inputMode] or {}
	
	local inputConfig = data[inputMode]
	inputConfig.press = inputConfig.press or {}
	inputConfig.release = inputConfig.release or {}
	
	inputConfig.press[key] = {
		press = {virtualKey},
		release = {}
	}
	inputConfig.release[key] = {
		press = {},
		release = {virtualKey}
	}
end

InputManager.setInputMode = function(self, inputMode)
	self.inputMode = inputMode
	self.inputConfig = self.data[inputMode]
end

InputManager.receive = function(self, event)
	if not self.inputConfig then
		return
	end
	
	local keyConfig
	if event.name == "keypressed" then
		keyConfig = self.inputConfig.press[event.args[1]]
	elseif event.name == "keyreleased" then
		keyConfig = self.inputConfig.release[event.args[1]]
	end
	if not keyConfig then
		return
	end
	
	local events = {}
	for _, key in ipairs(keyConfig.press) do
		events[#events + 1] = {
			name = "keypressed",
			args = {key},
			virtual = true
		}
	end
	for _, key in ipairs(keyConfig.release) do
		events[#events + 1] = {
			name = "keyreleased",
			args = {key},
			virtual = true
		}
	end
	for _, event in ipairs(events) do
		self:send(event)
	end
end

return InputManager
