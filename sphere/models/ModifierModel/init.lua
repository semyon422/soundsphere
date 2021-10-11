local Class			= require("aqua.util.Class")

local AutoPlay		= require("sphere.models.ModifierModel.AutoPlay")
local ProMode		= require("sphere.models.ModifierModel.ProMode")
local AutoKeySound	= require("sphere.models.ModifierModel.AutoKeySound")
local SpeedMode		= require("sphere.models.ModifierModel.SpeedMode")
local TimeRateQ		= require("sphere.models.ModifierModel.TimeRateQ")
local TimeRateX		= require("sphere.models.ModifierModel.TimeRateX")
local WindUp		= require("sphere.models.ModifierModel.WindUp")
local AudioClip		= require("sphere.models.ModifierModel.AudioClip")
local NoScratch		= require("sphere.models.ModifierModel.NoScratch")
local NoLongNote	= require("sphere.models.ModifierModel.NoLongNote")
local NoMeasureLine	= require("sphere.models.ModifierModel.NoMeasureLine")
local Automap		= require("sphere.models.ModifierModel.Automap")
local MultiplePlay	= require("sphere.models.ModifierModel.MultiplePlay")
local MinLnLength	= require("sphere.models.ModifierModel.MinLnLength")
local Alternate		= require("sphere.models.ModifierModel.Alternate")
local Alternate2		= require("sphere.models.ModifierModel.Alternate2")
local MultiOverPlay	= require("sphere.models.ModifierModel.MultiOverPlay")
local Alternate		= require("sphere.models.ModifierModel.Alternate")
local Shift			= require("sphere.models.ModifierModel.Shift")
local Mirror		= require("sphere.models.ModifierModel.Mirror")
local Random		= require("sphere.models.ModifierModel.Random")
local BracketSwap	= require("sphere.models.ModifierModel.BracketSwap")
local FullLongNote	= require("sphere.models.ModifierModel.FullLongNote")
local MinLnLength	= require("sphere.models.ModifierModel.MinLnLength")
local ToOsu			= require("sphere.models.ModifierModel.ToOsu")

local ModifierModel = Class:new()

local Modifiers = {
	AutoPlay,
	ProMode,
	AutoKeySound,
	SpeedMode,
	TimeRateQ,
	TimeRateX,
	WindUp,
	AudioClip,
	NoScratch,
	NoLongNote,
	NoMeasureLine,
	Automap,
	MultiplePlay,
	MultiOverPlay,
	Alternate,
	Alternate2,
	Shift,
	Mirror,
	Random,
	BracketSwap,
	FullLongNote,
	MinLnLength,
	ToOsu
}

local ModifierId = {
	[AutoPlay] = 0,
	[ProMode] = 1,
	[AutoKeySound] = 2,
	[SpeedMode] = 3,
	[TimeRateQ] = 4,
	[TimeRateX] = 5,
	[WindUp] = 6,
	[AudioClip] = 7,
	[NoScratch] = 8,
	[NoLongNote] = 9,
	[NoMeasureLine] = 10,
	[Automap] = 11,
	[MultiplePlay] = 12,
	[MultiOverPlay] = 13,
	[Alternate] = 14,
	[Shift] = 15,
	[Mirror] = 16,
	[Random] = 17,
	[BracketSwap] = 18,
	[FullLongNote] = 19,
	[MinLnLength] = 20,
	[ToOsu] = 21
}

local OneUseModifiers = {
	AutoPlay,
	ProMode,
	AutoKeySound,
	SpeedMode,
	TimeRateQ,
	TimeRateX,
	WindUp,
	AudioClip,
	NoScratch,
	NoLongNote,
	NoMeasureLine
}

ModifierModel.construct = function(self)
	self.modifiers = {}
	self.oneUseModifiers = {}
	self.modifierByName = {}
	self.modifierById = {}
	self:createModifiers()
end

ModifierModel.load = function(self)
	local config = self.configModel.configs.modifier
	self.config = config

	self.availableModifierItemIndex = 1
	self.modifierItemIndex = #config

	for _, modifierConfig in ipairs(self.config) do
		local modifier = self:getModifier(modifierConfig)
		if modifier then
			modifier.added = true
		end
	end
end

ModifierModel.scrollAvailableModifier = function(self, direction)
	if not self.modifiers[self.availableModifierItemIndex + direction] then
		return
	end
	self.availableModifierItemIndex = self.availableModifierItemIndex + direction
end

ModifierModel.scrollModifier = function(self, direction)
	local newModifierItemIndex = self.modifierItemIndex + direction
	if not self.config[newModifierItemIndex] and not self.config[newModifierItemIndex - 1] then
		return
	end
	self.modifierItemIndex = newModifierItemIndex
end

ModifierModel.createModifiers = function(self)
	local modifierByName = self.modifierByName
	local modifierById = self.modifierById
	for _, Modifier in ipairs(Modifiers) do
		local modifier = Modifier:new()
		modifier.modifierModel = self
		modifier.id = ModifierId[Modifier]
		modifierByName[modifier.name] = modifier
		modifierById[modifier.id] = modifier
		table.insert(self.modifiers, modifier)
		if self:isOneUseModifier(Modifier) then
			modifier.oneUse = true
			table.insert(self.oneUseModifiers, modifier)
		end
	end
end

ModifierModel.getModifier = function(self, modifierConfig)
	if type(modifierConfig) == "number" then
		return self.modifierById[modifierConfig]
	end
	return self.modifierByName[modifierConfig.name]
end

ModifierModel.isOneUseModifier = function(self, Modifier)
	for _, OneUseModifier in ipairs(OneUseModifiers) do
		if Modifier == OneUseModifier then
			return true
		end
	end
end

ModifierModel.getMinimalModifierIndex = function(self, modifier)
	local index = 1
	for _, oneUseModifier in ipairs(self.oneUseModifiers) do
		if oneUseModifier.added then
			index = index + 1
		end
		if modifier == oneUseModifier then
			return index
		end
	end
	return index
end

ModifierModel.add = function(self, modifier)
	local modifierConfig = modifier:getDefaultConfig()
	local config = self.config
	local minimalModifierIndex = self:getMinimalModifierIndex(modifier)
	local index = math.max(self.modifierItemIndex, minimalModifierIndex)
	if modifier.oneUse then
		if modifier.added then
			return
		end
		index = minimalModifierIndex
	end
	table.insert(config, index, modifierConfig)
	self.modifierItemIndex = index + 1
	modifier.added = true
end

ModifierModel.remove = function(self, modifierConfig)
	for i, foundModifierConfig in ipairs(self.config) do
		if foundModifierConfig == modifierConfig then
			table.remove(self.config, i)
			break
		end
	end
	if not self.config[self.modifierItemIndex] then
		self.modifierItemIndex = math.max(self.modifierItemIndex - 1, 0)
	end
	local modifier = self:getModifier(modifierConfig)
	for i, foundModifierConfig in ipairs(self.config) do
		if foundModifierConfig.name == modifierConfig.name then
			return
		end
	end
	modifier.added = false
end

ModifierModel.setModifierValue = function(self, modifierConfig, value)
	local modifier = self:getModifier(modifierConfig)
	modifier:setValue(modifierConfig, value)
end

ModifierModel.increaseModifierValue = function(self, modifierConfig, delta)
	local modifier = self:getModifier(modifierConfig)
	if type(modifier.defaultValue) == "number" then
		modifier:setValue(modifierConfig, modifierConfig.value + delta * modifier.step)
	elseif type(modifier.defaultValue) == "boolean" then
		local value = false
		if delta == 1 then
			value = true
		end
		modifier:setValue(modifierConfig, value)
	elseif type(modifier.defaultValue) == "string" then
		local indexValue = modifier:toIndexValue(modifierConfig.value)
		modifier:setValue(modifierConfig, modifier:fromIndexValue(indexValue + delta * modifier.step))
	end
end

ModifierModel.apply = function(self, modifierType)
	for _, modifierConfig in ipairs(self.config) do
		local modifier = self:getModifier(modifierConfig)
		if modifier and modifier.type == modifierType then
			modifier.noteChartModel = self.noteChartModel
			modifier.rhythmModel = self.rhythmModel
			modifier.difficultyModel = self.difficultyModel
			modifier.scoreModel = self.scoreModel
			modifier:apply(modifierConfig)
		end
	end
end

ModifierModel.update = function(self)
	for _, modifierConfig in ipairs(self.config) do
		local modifier = self:getModifier(modifierConfig)
		if modifier then
			modifier:update(modifierConfig)
		end
	end
end

ModifierModel.receive = function(self, event)
	for _, modifierConfig in ipairs(self.config) do
		local modifier = self:getModifier(modifierConfig)
		if modifier then
			modifier:receive(modifierConfig, event)
		end
	end
end

ModifierModel.encode = function(self, config)
	config = config or self.config
	local t = {}
	for _, modifierConfig in ipairs(config) do
		local modifier = self:getModifier(modifierConfig)
		if modifier then
			table.insert(t, ("%d:%s"):format(modifier.id, modifier:encode(modifierConfig)))
		end
	end
	return table.concat(t, ";")
end

ModifierModel.decode = function(self, encodedConfig)
	local config = {}
	for modifierId, modifierData in encodedConfig:gmatch("(%d+):([^;]+)") do
		local modifier = self:getModifier(tonumber(modifierId))
		if modifier then
			table.insert(config, modifier:decode(modifierData))
		end
	end
	return config
end

ModifierModel.fixOldFormat = function(self, oldConfig)
	for _, modifierConfig in ipairs(oldConfig) do
		local modifier = self:getModifier(modifierConfig)
		if modifier then
			if not modifierConfig.value then
				for k, v in pairs(modifierConfig) do
					if k ~= "name" then
						modifierConfig.value = v
					end
				end
			end
			if type(modifierConfig.value) == "number" and type(modifier.defaultValue) == "string" then
				modifierConfig.value = modifier:fromIndexValue(modifierConfig.value)
			end
		end
	end
end

return ModifierModel
