local Class = require("aqua.util.Class")
local serpent = require("serpent")

local ConfigModel = Class:new()

ConfigModel.construct = function(self)
	self.configs = {}
	self.paths = {}
end

local function copyTable(from, to)
	for key, value in pairs(from) do
		if type(value) == "table" then
			if type(to[key]) ~= "table" then
				to[key] = {}
			end
			copyTable(value, to[key])
		else
			to[key] = value
		end
	end
end

ConfigModel.readConfig = function(self, name, path, defaultPath)
	local configs = self.configs
	local paths = self.paths

	paths[name] = path
	configs[name] = {}
	local config = configs[name]

	if defaultPath then
		copyTable(self:readConfigFile(defaultPath), config)
	end
	copyTable(self:readConfigFile(path), config)
end

ConfigModel.writeConfig = function(self, name)
	local config = assert(self.configs[name])
	local path = self.paths[name]
	return self:writeConfigFile(path, config)
end

ConfigModel.readConfigFile = function(self, path)
	local info = love.filesystem.getInfo(path)
	if not info or info.size == 0 then
		return {}
	end

	return love.filesystem.load(path)()
end

local serpentOptions = {
	indent = "\t",
	comment = false,
	sortkeys = true,
	numformat = "%.16g"
}
local serpentFormat = "return %s\n"
ConfigModel.writeConfigFile = function(self, path, config)
	return assert(love.filesystem.write(path, serpentFormat:format(serpent.block(config, serpentOptions))))
end

return ConfigModel
