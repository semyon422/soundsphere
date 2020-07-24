local Config = require("sphere.config.Config")

local GameConfig = Config:new()

GameConfig:setPath("userdata/config.json")

GameConfig.defaultValues = {
	["audio.primaryAudioMode"] = "streamMemoryReversable",
	["audio.secondaryAudioMode"] = "sample",

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
	["gameplay.increaseTimeRate"] = "f6"
}

GameConfig:setDefaultValues()

return GameConfig
