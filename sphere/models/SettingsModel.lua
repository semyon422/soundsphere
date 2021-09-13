local Class = require("aqua.util.Class")
local round = require("aqua.math").round
local map = require("aqua.math").map
local inside = require("aqua.util.inside")
local outside = require("aqua.util.outside")

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
	outside(self.config, settingConfig.key, value)
end

SettingsModel.increaseValue = function(self, settingConfig, delta)
	local key = settingConfig.key
	local value = inside(self.config, key)
	if settingConfig.type == "slider" then
		value = math.min(math.max(value + settingConfig.step * delta, settingConfig.range[1]), settingConfig.range[2])
	elseif settingConfig.type == "stepper" then
		value = settingConfig.values[math.min(math.max(self:getValue(settingConfig) + delta, 1), #settingConfig.values)]
	end
	outside(self.config, key, value)
end

SettingsModel.getValue = function(self, settingConfig)
	local value = inside(self.config, settingConfig.key)
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

SettingsModel.toNormValue = function(self, settingConfig)
	local value = inside(self.config, settingConfig.key)
	local range = settingConfig.range
	if settingConfig.type == "slider" then
		return map(value, range[1], range[2], 0, 1)
	end
end

SettingsModel.toIndexValue = function(self, settingConfig)
	local value = inside(self.config, settingConfig.key)
	if not settingConfig.values then
		return round((value - settingConfig.range[1]) / settingConfig.step) + 1
	end
	for i, currentValue in ipairs(settingConfig.values) do
		if type(currentValue) == "table" then
			local different = false
			for k, v in pairs(currentValue) do
				if v ~= value[k] then
					different = true
				end
			end
			if not different then
				return i
			end
		elseif value == currentValue then
			return i
		end
	end
	return 1
end

SettingsModel.fromIndexValue = function(self, settingConfig, indexValue)
	if not settingConfig.values then
		return settingConfig.range[1] + (indexValue - 1) * settingConfig.step
	end
	indexValue = math.min(math.max(indexValue, 1), #settingConfig.values)
	return settingConfig.values[indexValue]
end

SettingsModel.getCount = function(self, settingConfig)
	if settingConfig.range then
		return round((settingConfig.range[2] - settingConfig.range[1]) / settingConfig.step) + 1
	elseif settingConfig.values then
		return #settingConfig.values
	end
end

SettingsModel.getDisplayValue = function(self, settingConfig)
	local value = inside(self.config, settingConfig.key)
	local range = settingConfig.range
	local displayRange = settingConfig.displayRange or range
	if settingConfig.type == "slider" then
		value = settingConfig.format:format(map(value, range[1], range[2], displayRange[1], displayRange[2]))
	elseif settingConfig.type == "switch" then
		value = value and displayRange[2] or displayRange[1]
	elseif settingConfig.type == "stepper" then
		local indexValue = self:toIndexValue(settingConfig)
		value = (settingConfig.displayValues or settingConfig.values)[indexValue]
	end
	if settingConfig.format then
		local format = settingConfig.format
		if type(format) == "string" then
			value = format:format(value)
		elseif type(format) == "function" then
			value = format(value)
		end
	end
	return value
end

return SettingsModel
