local class = require("class")
local serpent = require("serpent")

---@class sphere.Configs
---@field files sphere.FilesConfig
---@field filters sphere.FiltersConfig
---@field input sphere.InputConfig
---@field judgements sphere.JudgementsConfig
---@field online sphere.OnlineConfig
---@field play sphere.PlayConfig
---@field select sphere.SelectConfig
---@field settings sphere.SettingsConfig
---@field urls sphere.UrlsConfig

---@class sphere.ConfigModel
---@operator call: sphere.ConfigModel
---@field configs sphere.Configs
local ConfigModel = class()

ConfigModel.userdataPath = "userdata"
ConfigModel.configModelPath = "sphere/persistence/ConfigModel"

function ConfigModel:new()
	self.configs = {}
	self.openedConfigs = {}
end

---@param name string
---@param mode boolean?
function ConfigModel:open(name, mode)
	self.openedConfigs[name] = mode == true
end

---@param src table
---@param dst table
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

---@param name string
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

---@param name string
---@return boolean
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

---@param path string
---@return any?
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

---@param path string
---@param config table
---@return boolean
function ConfigModel:writeFile(path, config)
	return assert(love.filesystem.write(path, serpentFormat:format(serpent.block(config, serpentOptions))))
end

return ConfigModel
