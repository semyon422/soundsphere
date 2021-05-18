local Class = require("aqua.util.Class")
local round = require("aqua.math").round
local map = require("aqua.math").map

local SettingsModel = Class:new()

SettingsModel.construct = function(self)
	self.settingsMap = {}
	self.sectionsMap = {}
	self.sections = {}
end

SettingsModel.load = function(self)
	self.config = self.configModel:getConfig("settings")
	self.config_model = self.configModel:getConfig("settings_model")

	self:loadStructure()
end

SettingsModel.loadStructure = function(self)
	local config_model = self.config_model
	local settingsMap = self.settingsMap
	local sectionsMap = self.sectionsMap
	local sections = self.sections

	for _, config in ipairs(config_model) do
		settingsMap[config.section] = settingsMap[config.section] or {}
		settingsMap[config.section][config.key] = config

		if not sectionsMap[config.section] then
			sectionsMap[config.section] = {}
			table.insert(sections, sectionsMap[config.section])
		end
		table.insert(sectionsMap[config.section], config)
	end
end

SettingsModel.setValue = function(self, settingConfig, value)
	self.config[settingConfig.section][settingConfig.key] = value
end

SettingsModel.increaseValue = function(self, settingConfig, delta)
	local section = settingConfig.section
	local key = settingConfig.key
	local value = self.config[section][key]
	if settingConfig.type == "slider" then
		self.config[section][key] = math.min(math.max(value + settingConfig.step * delta, settingConfig.range[1]), settingConfig.range[2])
	elseif settingConfig.type == "stepper" then
		self.config[section][key] = settingConfig.values[math.min(math.max(self:getValue(settingConfig) + delta, 1), #settingConfig.values)]
	elseif settingConfig.type == "switch" then
		self.config[section][key] = math.min(math.max(value + delta, 0), 1)
	end
end

SettingsModel.getValue = function(self, settingConfig)
	local value = self.config[settingConfig.section][settingConfig.key]
	if settingConfig.type == "stepper" then
		for i, listValue in ipairs(settingConfig.values) do
			if value == listValue then
				return i
			end
		end
	end
	return value
end

SettingsModel.fromNormValue = function(self, settingConfig, value)
	if settingConfig.type == "slider" then
		return round(settingConfig.range[1] + value * (settingConfig.range[2] - settingConfig.range[1]), settingConfig.step)
	end
end

SettingsModel.getNormValue = function(self, settingConfig)
	local value = self.config[settingConfig.section][settingConfig.key]
	local range = settingConfig.range
	if settingConfig.type == "slider" then
		return map(value, range[1], range[2], 0, 1)
	end
end

SettingsModel.getDisplayValue = function(self, settingConfig)
	local value = self.config[settingConfig.section][settingConfig.key]
	local range = settingConfig.range
	local displayRange = settingConfig.displayRange or range
	if settingConfig.type == "slider" then
		return settingConfig.format:format(map(value, range[1], range[2], displayRange[1], displayRange[2]))
	elseif settingConfig.type == "switch" then
		return value == 0 and displayRange[1] or displayRange[2]
	end
	return ""
end

return SettingsModel
