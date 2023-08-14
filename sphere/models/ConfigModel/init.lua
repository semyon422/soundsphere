local class = require("class")
local serpent = require("serpent")

local ConfigModel = class()

ConfigModel.userdataPath = "userdata"
ConfigModel.configModelPath = "sphere/models/ConfigModel"

function ConfigModel:new()
	self.configs = {}
	self.openedConfigs = {}
end

function ConfigModel:open(name, mode)
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

function ConfigModel:_read(name)
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

function ConfigModel:read()
	for name in pairs(self.openedConfigs) do
		self:_read(name)
	end
end

function ConfigModel:_write(name)
	local config = assert(self.configs[name])
	local path = self.userdataPath .. "/" .. name .. ".lua"
	return self:writeFile(path, config)
end

function ConfigModel:write()
	for name, writable in pairs(self.openedConfigs) do
		if writable then
			self:_write(name)
		end
	end
end

function ConfigModel:readFile(path)
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
function ConfigModel:writeFile(path, config)
	return assert(love.filesystem.write(path, serpentFormat:format(serpent.block(config, serpentOptions))))
end

return ConfigModel
