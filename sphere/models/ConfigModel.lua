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
	if info and info.size ~= 0 then
		local contents = love.filesystem.read(self.path)
		self:setTable(json.decode(contents))
	end
	self:setDefaultValues()
end

ConfigModel.write = function(self)
	love.filesystem.write(self.path, json.encode(self.data))
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
		if data[key] ~= nil then
			self:set(key, data[key])
		else
			self:set(key, value)
		end
	end
end

ConfigModel.defaultValues = {
	["audio.primaryAudioMode"] = "streamMemoryTempo",
	["audio.secondaryAudioMode"] = "sample",
	["audio.previewAudioMode"] = "streamOpenAL",

	["dim.select"] = 0.5,
	["dim.gameplay"] = 0.75,
	["dim.result"] = 0.75,

	["speed"] = 1,
	["fps"] = 240,
	["theme"] = "",

	["volume.global"] = 1,
	["volume.music"] = 1,
	["volume.effects"] = 1,

	["screen.settings"] = "f1",
	["screen.browser"] = "tab",
	["gameplay.pause"] = "escape",
	["gameplay.skipIntro"] = "space",
	["gameplay.quickRestart"] = "`",
	["gameplay.timeToPrepare"] = 2,
	["gameplay.inputOffset"] = 0,
	["select.selectRandomNoteChartSet"] = "f2",
	["select.adjustDifficultyAccuracy"] = 26,
	["select.adjustDifficultyPerformance"] = 300,
	["select.adjustDifficulty"] = "f3",

	["gameplay.invertPlaySpeed"] = "f2",
	["gameplay.decreasePlaySpeed"] = "f3",
	["gameplay.increasePlaySpeed"] = "f4",

	["gameplay.invertTimeRate"] = "f7",
	["gameplay.decreaseTimeRate"] = "f5",
	["gameplay.increaseTimeRate"] = "f6",
	["gameplay.needTimeRound"] = true,
	["gameplay.videobga"] = false,
	["gameplay.imagebga"] = true,

	["screenshot.capture"] = "f12",
	["screenshot.open"] = "lshift",

	["replay.type"] = "NanoChart",

	["online.host"] = "https://soundsphere.xyz",
	["online.session"] = "",
	["online.token"] = "",
	["online.userId"] = 1,
	["online.email"] = "",
	["online.quick_login_key"] = "",

	["parser.midiConstantVolume"] = false
}

return ConfigModel
