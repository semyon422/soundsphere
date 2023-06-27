local Class = require("Class")
local serpent = require("serpent")

local ConfigModel = Class:new()

ConfigModel.userdataPath = "userdata"
ConfigModel.configModelPath = "sphere/models/ConfigModel"

ConfigModel.construct = function(self)
	self.configs = {}
	self.openedConfigs = {}
end

ConfigModel.open = function(self, name, mode)
	self.openedConfigs[name] = mode == true
end

local function copyTable(src, dst)
	for k, v in pairs(src) do
		if type(v) == "table" then
			if type(dst[k]) ~= "table" then
				dst[k] = {}
			end
			copyTable(v, dst[k])
		else
			dst[k] = v
		end
	end
end

ConfigModel._read = function(self, name)
	local configs = self.configs
	configs[name] = {}
	local config = configs[name]

	local path = self.userdataPath .. "/" .. name .. ".lua"
	local defaultPath = self.configModelPath .. "/" .. name .. ".lua"

	if defaultPath then
		copyTable(self:readFile(defaultPath), config)
	end

	local c = self:readFile(path)
	if type(c) == "table" then
		copyTable(c, config)
	elseif type(c) == "function" then
		c(config)
	end
end

ConfigModel.read = function(self)
	for name in pairs(self.openedConfigs) do
		self:_read(name)
	end
end

ConfigModel._write = function(self, name)
	local config = assert(self.configs[name])
	local path = self.userdataPath .. "/" .. name .. ".lua"
	return self:writeFile(path, config)
end

ConfigModel.write = function(self)
	for name, writable in pairs(self.openedConfigs) do
		if writable then
			self:_write(name)
		end
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
