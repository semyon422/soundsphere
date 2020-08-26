local Observable	= require("aqua.util.Observable")
local Class			= require("aqua.util.Class")
local json			= require("json")

local ConfigModel = Class:new()

ConfigModel.path = "config.json"
ConfigModel.defaultValues = {}

ConfigModel.construct = function(self)
	self.data = {}
	self.observable = Observable:new()
	self:setDefaultValues()
end

ConfigModel.setPath = function(self, path)
	self.path = path
end

ConfigModel.read = function(self)
	local info = love.filesystem.getInfo(self.path)
	if info then
		local file = io.open(self.path, "r")
		self:setTable(json.decode(file:read("*all")))
		file:close()
	end
	self:setDefaultValues()
end

ConfigModel.write = function(self)
	local file = io.open(self.path, "w")
	file:write(json.encode(self.data))
	return file:close()
end

ConfigModel.get = function(self, key)
	return self.data[key]
end

ConfigModel.setTable = function(self, t)
	for key, value in pairs(t) do
		self:set(key, value)
	end
end

ConfigModel.set = function(self, key, value)
	self.data[key] = value
	return self.observable:send({
		name = "ConfigModel.set",
		key = key,
		value = value
	})
end

ConfigModel.setDefaultValues = function(self)
	local data = self.data

	for key, value in pairs(self.defaultValues) do
		-- print(key)
		self:set(key, data[key] ~= nil and data[key] or value)
	end
end

ConfigModel.defaultValues = {
	["audio.primaryAudioMode"] = "streamMemoryReversable",
	["audio.secondaryAudioMode"] = "sample",
	["audio.previewAudioMode"] = "streamUser",

	["dim.select"] = 0.5,
	["dim.gameplay"] = 0.75,

	["speed"] = 1,
	["fps"] = 240,

	["volume.global"] = 1,
	["volume.music"] = 1,
	["volume.effects"] = 1,

	["screen.settings"] = "f1",
	["screen.browser"] = "tab",
	["gameplay.pause"] = "escape",
	["gameplay.skipIntro"] = "space",
	["gameplay.quickRestart"] = "`",
	["select.selectRandomNoteChartSet"] = "f2",

	["gameplay.invertPlaySpeed"] = "f2",
	["gameplay.decreasePlaySpeed"] = "f3",
	["gameplay.increasePlaySpeed"] = "f4",

	["gameplay.invertTimeRate"] = "f7",
	["gameplay.decreaseTimeRate"] = "f5",
	["gameplay.increaseTimeRate"] = "f6",

	["screenshot.capture"] = "f12",
	["screenshot.open"] = "lshift",

	["replay.type"] = "NanoChart"
}

return ConfigModel
