local Observable	= require("aqua.util.Observable")
local Class			= require("aqua.util.Class")
local json			= require("json")

local Config = Class:new()

Config.path = "config.json"
Config.defaultValues = {}

Config.construct = function(self)
	self.data = {}
	self.observable = Observable:new()
	self:setDefaultValues()
end

Config.setPath = function(self, path)
	self.path = path
end

Config.read = function(self)
	if love.filesystem.exists(self.path) then
		local file = io.open(self.path, "r")
		self:setTable(json.decode(file:read("*all")))
		file:close()
	end
end

Config.write = function(self)
	local file = io.open(self.path, "w")
	file:write(json.encode(self.data))
	return file:close()
end

Config.get = function(self, key)
	return self.data[key]
end

Config.setTable = function(self, t)
	for key, value in pairs(t) do
		self:set(key, value)
	end
end

Config.set = function(self, key, value)
	local oldValue = self.data[key]
	if oldValue ~= value then
		self.data[key] = value
		return self.observable:send({
			name = "Config.set",
			key = key,
			value = value
		})
	end
end

Config.setDefaultValues = function(self)
	local data = self.data

	for key, value in pairs(self.defaultValues) do
		data[key] = data[key] ~= nil and data[key] or value
	end
end

return Config
