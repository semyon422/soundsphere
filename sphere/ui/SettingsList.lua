local CoordinateManager		= require("aqua.graphics.CoordinateManager")
local SettingsListButton	= require("sphere.ui.SettingsListButton")
local CustomList			= require("sphere.ui.CustomList")

local SettingsList = CustomList:new()

SettingsList.x = 0.5
SettingsList.y = 0
SettingsList.w = 1
SettingsList.h = 1

SettingsList.sender = "SettingsList"
SettingsList.needFocusToInteract = false

SettingsList.buttonCount = 17
SettingsList.middleOffset = 9
SettingsList.startOffset = 9
SettingsList.endOffset = 9

SettingsList.category = "general"
SettingsList.Button = SettingsListButton

SettingsList.init = function(self)
	self.cs = CoordinateManager:getCS(0, 0, 0, 0, "h")
end

SettingsList.load = function(self)
	self:addItems()
	self:reload()
end

SettingsList.send = function(self, event)
	if event.action == "buttonInteract" then
		local item = self.items[event.itemIndex]
		if event.button == 1 then
		elseif event.button == 2 then
		end
	end
	
	return CustomList.send(self, event)
end

SettingsList.receive = function(self, event)
	if event.name == "keypressed" then
		local key = event.args[1]
		if key == "f5" then
		end
	elseif event.action == "scrollTarget" then
		local item = event.list.items[event.itemIndex]
		if item and event.list.sender == "CategoriesList" then
			self.category = item.category
			self:addItems()
		end
	end
	
	return CustomList.receive(self, event)
end

SettingsList.addItems = function(self)
	if self.category == "general" then
		self:setGeneralItems()
	elseif self.category == "graphics" then
		self:setGraphicsItems()
	elseif self.category == "sound" then
		self:setSoundItems()
	elseif self.category == "input" then
		self:setInputItems()
	end
end

SettingsList.setGeneralItems = function(self)
	local items = {}

	items[#items + 1] = {
		name = "FPS limit",
		configKey = "fps",
		type = "slider",
		minValue = 10,
		maxValue = 1000,
		minDisplayValue = 10,
		maxDisplayValue = 1000,
		step = 10,
		format = "%d"
	}
	items[#items + 1] = {
		name = "play speed",
		configKey = "speed",
		type = "slider",
		minValue = 0,
		maxValue = 3,
		minDisplayValue = 0,
		maxDisplayValue = 3,
		step = 0.05,
		format = "%0.2f"
	}
	items[#items + 1] = {
		name = "replay type",
		configKey = "replay.type",
		type = "listSwitcher",
		valueList = {"NanoChart", "Json"},
		displayList = {"NanoChart", "Json"}
	}
	items[#items + 1] = {
		name = "round off time?",
		configKey = "gameplay.needTimeRound",
		type = "checkbox",
		minValue = false,
		maxValue = true,
		minDisplayValue = "no",
		maxDisplayValue = "yes"
	}
	items[#items + 1] = {
		name = "video BGA",
		configKey = "gameplay.videobga",
		type = "checkbox",
		minValue = false,
		maxValue = true,
		minDisplayValue = "disabled",
		maxDisplayValue = "enabled"
	}
	items[#items + 1] = {
		name = "image BGA",
		configKey = "gameplay.imagebga",
		type = "checkbox",
		minValue = false,
		maxValue = true,
		minDisplayValue = "disabled",
		maxDisplayValue = "enabled"
	}
	
	return self:setItems(items)
end

SettingsList.setGraphicsItems = function(self)
	local items = {}
	
	items[#items + 1] = {
		name = "dim select",
		configKey = "dim.select",
		type = "slider",
		minValue = 0,
		maxValue = 1,
		minDisplayValue = 0,
		maxDisplayValue = 100,
		step = 0.01,
		format = "%d"
	}
	items[#items + 1] = {
		name = "dim gameplay",
		configKey = "dim.gameplay",
		type = "slider",
		minValue = 0,
		maxValue = 1,
		minDisplayValue = 0,
		maxDisplayValue = 100,
		step = 0.01,
		format = "%d"
	}
	items[#items + 1] = {
		name = "dim result",
		configKey = "dim.result",
		type = "slider",
		minValue = 0,
		maxValue = 1,
		minDisplayValue = 0,
		maxDisplayValue = 100,
		step = 0.01,
		format = "%d"
	}
	
	return self:setItems(items)
end

SettingsList.setSoundItems = function(self)
	local items = {}
	
	items[#items + 1] = {
		name = "primary audio mode",
		configKey = "audio.primaryAudioMode",
		type = "listSwitcher",
		valueList = {
			"sample", "stream", "streamTempo",
			"streamUser", "streamUserTempo",
			"streamMemoryTempo", "streamMemoryReversable",
			"streamOpenAL", "sampleOpenAL"
		},
		displayList = {
			"sample", "stream", "tempo",
			"stream*", "tempo*",
			"memory", "reversable",
			"streamOAL", "sampleOAL"
		}
	}
	items[#items + 1] = {
		name = "secondary audio mode",
		configKey = "audio.secondaryAudioMode",
		type = "listSwitcher",
		valueList = {
			"sample", "stream", "streamTempo",
			"streamUser", "streamUserTempo",
			"streamMemoryTempo", "streamMemoryReversable",
			"streamOpenAL", "sampleOpenAL"
		},
		displayList = {
			"sample", "stream", "tempo",
			"stream*", "tempo*",
			"memory", "reversable",
			"streamOAL", "sampleOAL"
		}
	}
	items[#items + 1] = {
		name = "preview audio mode",
		configKey = "audio.previewAudioMode",
		type = "listSwitcher",
		valueList = {"stream", "streamTempo", "streamUser", "streamUserTempo", "streamOpenAL"},
		displayList = {"stream", "tempo", "stream*", "tempo*", "streamOAL"}
	}
	items[#items + 1] = {
		name = "global volume",
		configKey = "volume.global",
		type = "slider",
		minValue = 0,
		maxValue = 1,
		minDisplayValue = 0,
		maxDisplayValue = 100,
		step = 0.01,
		format = "%d"
	}
	items[#items + 1] = {
		name = "music volume",
		configKey = "volume.music",
		type = "slider",
		minValue = 0,
		maxValue = 1,
		minDisplayValue = 0,
		maxDisplayValue = 100,
		step = 0.01,
		format = "%d"
	}
	items[#items + 1] = {
		name = "effects volume",
		configKey = "volume.effects",
		type = "slider",
		minValue = 0,
		maxValue = 1,
		minDisplayValue = 0,
		maxDisplayValue = 100,
		step = 0.01,
		format = "%d"
	}
	
	return self:setItems(items)
end

SettingsList.setInputItems = function(self)
	local items = {}
	
	items[#items + 1] = {
		name = "settings",
		type = "keybind",
		configKey = "screen.settings"
	}
	items[#items + 1] = {
		name = "browser",
		type = "keybind",
		configKey = "screen.browser"
	}
	items[#items + 1] = {
		name = "pause",
		type = "keybind",
		configKey = "gameplay.pause"
	}
	items[#items + 1] = {
		name = "skip intro",
		type = "keybind",
		configKey = "gameplay.skipIntro"
	}
	items[#items + 1] = {
		name = "quick restart",
		type = "keybind",
		configKey = "gameplay.quickRestart"
	}
	items[#items + 1] = {
		name = "select random song",
		type = "keybind",
		configKey = "select.selectRandomNoteChartSet"
	}
	items[#items + 1] = {
		name = "invert play speed",
		type = "keybind",
		configKey = "gameplay.invertPlaySpeed"
	}
	items[#items + 1] = {
		name = "decrease play speed",
		type = "keybind",
		configKey = "gameplay.decreasePlaySpeed"
	}
	items[#items + 1] = {
		name = "increase play speed",
		type = "keybind",
		configKey = "gameplay.increasePlaySpeed"
	}
	items[#items + 1] = {
		name = "invert time rate",
		type = "keybind",
		configKey = "gameplay.invertTimeRate"
	}
	items[#items + 1] = {
		name = "decrease time rate",
		type = "keybind",
		configKey = "gameplay.decreaseTimeRate"
	}
	items[#items + 1] = {
		name = "increase time rate",
		type = "keybind",
		configKey = "gameplay.increaseTimeRate"
	}
	items[#items + 1] = {
		name = "capture screenshot",
		type = "keybind",
		configKey = "screenshot.capture"
	}
	items[#items + 1] = {
		name = "open screenshot",
		type = "keybind",
		configKey = "screenshot.open"
	}

	return self:setItems(items)
end

return SettingsList
