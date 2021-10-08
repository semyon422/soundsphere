local Class = require("aqua.util.Class")
local toml = require("lua-toml.toml")
local json = require("json")
local serpent = require("serpent")
toml.strict = false

local ConfigModel = Class:new()

ConfigModel.construct = function(self)
	self.configs = {}
	self.paths = {}
	self.defaultPaths = {}
	self.formats = {}
end

ConfigModel.addConfig = function(self, name, path, defaultPath, format)
	local configs = self.configs
	local paths = self.paths
	local defaultPaths = self.defaultPaths
	local formats = self.formats
	assert(not configs[name])

	configs[name] = {}
	paths[name] = path
	defaultPaths[name] = defaultPath
	formats[name] = format
end

ConfigModel.readConfig = function(self, name)
	local config = assert(self.configs[name])

	local path = self.paths[name]
	local defaultPath = self.defaultPaths[name]
	local format = self.formats[name]
	if defaultPath then
		self:copyTable(self:readConfigFile(defaultPath, format), config)
	end
	self:copyTable(self:readConfigFile(path, format), config)
end

ConfigModel.writeConfig = function(self, name)
	local config = assert(self.configs[name])
	local format = self.formats[name]
	local path = self.paths[name]
	return self:writeConfigFile(path, format, config)
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

ConfigModel.readConfigFile = function(self, path, format)
	local info = love.filesystem.getInfo(path)
	if not info or info.size == 0 then
		return {}
	end

	if format == "toml" then
		return self:readTomlFile(path)
	elseif format == "json" then
		return self:readJsonFile(path)
	elseif format == "lua" then
		return love.filesystem.load(path)()
	end
end

ConfigModel.readTomlFile = function(self, path)
	local contents = love.filesystem.read(path)
	return assert(toml.parse(contents))
end

ConfigModel.readJsonFile = function(self, path)
	local contents = love.filesystem.read(path)
	return assert(json.decode(contents))
end

ConfigModel.writeConfigFile = function(self, path, format, config)
	if format == "toml" then
		return self:writeTomlFile(path, config)
	elseif format == "json" then
		return self:writeJsonFile(path, config)
	elseif format == "lua" then
		return self:writeLuaFile(path, config)
	end
end

ConfigModel.writeTomlFile = function(self, path, config)
	return assert(love.filesystem.write(path, toml.encode(config)))
end

ConfigModel.writeJsonFile = function(self, path, config)
	return assert(love.filesystem.write(path, json.encode(config)))
end

local serpentOptions = {
	indent = "\t",
	comment = false,
	sortkeys = true,
	numformat = "%.16g"
}
local serpentFormat = "return %s\n"
ConfigModel.writeLuaFile = function(self, path, config)
	return assert(love.filesystem.write(path, serpentFormat:format(serpent.block(config, serpentOptions))))
end

return ConfigModel
