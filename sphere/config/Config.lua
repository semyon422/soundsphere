local Observable	= require("aqua.util.Observable")
local json			= require("json")

local Config = {}

Config.path = "userdata/config.json"

Config.init = function(self)
	self.observable = Observable:new()
end

Config.send = function(self, event)
	return self.observable:send(event)
end

Config.read = function(self)
	self.data = {}
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

Config.setDefaultValues = function(self)
	local data = self.data
	
	data["dim.select"] = data["dim.select"] or 0.5
	data["dim.gameplay"] = data["dim.gameplay"] or 0.75
	
	data["speed"] = data["speed"] or 1
	data["fps"] = data["fps"] or 240
	
	data["volume.global"] = data["volume.global"] or 1
	data["volume.music"] = data["volume.music"] or 1
	data["volume.effects"] = data["volume.effects"] or 1
end

return Config
