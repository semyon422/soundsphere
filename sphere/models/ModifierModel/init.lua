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
	Shift,
	Mirror,
	Random,
	BracketSwap,
	FullLongNote,
	MinLnLength,
	ToOsu
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
	self:createModifiers()
end

ModifierModel.load = function(self)
	local config = self.configModel:getConfig("modifier")
	self.config = config

	self.availableModifierItemIndex = 1
	self.modifierItemIndex = #config

	for _, modifierConfig in ipairs(self.config) do
		self:getModifier(modifierConfig).added = true
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
	for _, Modifier in ipairs(Modifiers) do
		local modifier = Modifier:new()
		modifier.modifierModel = self
		modifierByName[modifier.name] = modifier
		table.insert(self.modifiers, modifier)
		if self:isOneUseModifier(Modifier) then
			modifier.oneUse = true
			table.insert(self.oneUseModifiers, modifier)
		end
	end
end

ModifierModel.getModifier = function(self, modifierConfig)
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
		return
	end
	local indexValue = modifier:toIndexValue(modifierConfig.value)
	modifier:setValue(modifierConfig, modifier:fromIndexValue(indexValue + delta * modifier.step))
end

ModifierModel.apply = function(self, modifierType)
	for _, modifierConfig in ipairs(self.config) do
		local modifier = self:getModifier(modifierConfig)
		if modifier.type == modifierType then
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
		modifier:update(modifierConfig)
	end
end

ModifierModel.receive = function(self, event)
	for _, modifierConfig in ipairs(self.config) do
		local modifier = self:getModifier(modifierConfig)
		modifier:receive(modifierConfig, event)
	end
end

ModifierModel.getString = function(self)
	local t = {}
	for _, modifierConfig in ipairs(self.config) do
		local modifier = self:getModifier(modifierConfig)
		table.insert(t, modifier:getString(modifierConfig) .. (modifier:getSubString(modifierConfig) or ""))
	end
	return table.concat(t, ",")
end

return ModifierModel
