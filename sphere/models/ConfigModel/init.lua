local Class = require("aqua.util.Class")
local toml = require("lua-toml.toml")
toml.strict = false

local ConfigModel = Class:new()

ConfigModel.construct = function(self)
	self.configs = {}
	self.paths = {}
	self.defaultPaths = {}
end

ConfigModel.addConfig = function(self, name, path, defaultPath)
	local configs = self.configs
	local paths = self.paths
	local defaultPaths = self.defaultPaths
	assert(not configs[name])

	configs[name] = {}
	paths[name] = path
	defaultPaths[name] = defaultPath
end

ConfigModel.readConfig = function(self, name)
	local config = assert(self.configs[name])

	local path = self.paths[name]
	local defaultPath = self.defaultPaths[name]
	if defaultPath then
		self:copyTable(self:readTomlFile(defaultPath), config)
	end
	self:copyTable(self:readTomlFile(path), config)
end

ConfigModel.writeConfig = function(self, name)
	return self:writeTomlFile(self.paths[name], assert(self.configs[name]))
end

ConfigModel.copyTable = function(self, from, to)
	for key, value in pairs(from) do
		if type(value) == "table" then
			to[key] = to[key] or {}
			self:copyTable(value, to[key])
		else
			to[key] = value
		end
	end
end

ConfigModel.readTomlFile = function(self, path)
	local info = love.filesystem.getInfo(path)
	if info and info.size ~= 0 then
		local file = io.open(path, "r")
		local data = assert(toml.parse(file:read("*all")))
		file:close()
		return data
	end
	return {}
end

ConfigModel.writeTomlFile = function(self, path, config)
	local file = io.open(path, "w")
	file:write(toml.encode(config))
	return file:close()
end

ConfigModel.getConfig = function(self, name)
	return assert(self.configs[name])
end

return ConfigModel
