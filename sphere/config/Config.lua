local Observable	= require("aqua.util.Observable")
local json			= require("json")

local Config = {}

Config.path = "userdata/config.json"

Config.init = function(self)
	self.data = {}
	self.observable = Observable:new()
end

Config.send = function(self, event)
	return self.observable:send(event)
end

Config.read = function(self)
	if love.filesystem.exists(self.path) then
		local file = io.open(self.path, "r")
		self.data = json.decode(file:read("*all"))
		file:close()
	end
	self:setDefaultValues()
end

Config.write = function(self)
	local file = io.open(self.path, "w")
	file:write(json.encode(self.data))
	return file:close()
end

Config.get = function(self, key)
	return self.data[key]
end

Config.set = function(self, key, value)
	self.data[key] = value
	return self:send({
		name = "Config.set",
		key = key,
		value = value
	})
end

Config.setNoEvent = function(self, key, value)
	self.data[key] = value
end

Config.setDefaultValues = function(self)
	local data = self.data
	
	for key, value in pairs(self.defaultValues) do
		data[key] = data[key] ~= nil and data[key] or value
	end
end

Config.defaultValues = {
	["cb"] = false,
	["kb"] = "",

	["audio.stream"] = false,
	
	["dim.select"] = 0.5,
	["dim.gameplay"] = 0.75,
	
	["speed"] = 1,
	["fps"] = 240,
	-- ["tps"] = 240,
	
	["volume.global"] = 1,
	["volume.music"] = 1,
	["volume.effects"] = 1,
	
	["screen.settings"] = "f1",
	["screen.browser"] = "tab",
	["gameplay.quickRestart"] = "`",
}

return Config
