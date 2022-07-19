local Class = require("aqua.util.Class")
local serpent = require("serpent")

local ConfigModel = Class:new()

ConfigModel.userdataPath = "userdata"
ConfigModel.configModelPath = "sphere/models/ConfigModel"

ConfigModel.construct = function(self)
	self.configs = {}
	self.paths = {}
	self.notWritable = {}
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

ConfigModel._read = function(self, name)
	local configs = self.configs
	local paths = self.paths

	local path = self.userdataPath .. "/" .. name .. ".lua"
	local defaultPath = self.configModelPath .. "/" .. name .. ".lua"

	paths[name] = path
	configs[name] = {}
	local config = configs[name]

	if defaultPath then
		copyTable(self:readFile(defaultPath), config)
	end

	local c = self:readFile(path)
	if type(c) == "table" then
		copyTable(c, config)
	elseif type(c) == "function" then
		self.notWritable[name] = true
		c(config)
	end
end

ConfigModel.read = function(self, ...)
	for i = 1, select("#", ...) do
		self:_read(select(i, ...))
	end
end

ConfigModel._write = function(self, name)
	if self.notWritable[name] then
		return
	end
	local config = assert(self.configs[name])
	local path = self.paths[name]
	return self:writeFile(path, config)
end

ConfigModel.write = function(self, ...)
	for i = 1, select("#", ...) do
		self:_write(select(i, ...))
	end
end

ConfigModel.readFile = function(self, path)
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
ConfigModel.writeFile = function(self, path, config)
	return assert(love.filesystem.write(path, serpentFormat:format(serpent.block(config, serpentOptions))))
end

return ConfigModel
