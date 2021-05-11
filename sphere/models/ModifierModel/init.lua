local Class			= require("aqua.util.Class")

local AutoPlay		= require("sphere.models.ModifierModel.AutoPlay")
local Automap		= require("sphere.models.ModifierModel.Automap")
local ProMode		= require("sphere.models.ModifierModel.ProMode")
local WindUp		= require("sphere.models.ModifierModel.WindUp")
local SpeedMode		= require("sphere.models.ModifierModel.SpeedMode")
local TimeRateQ		= require("sphere.models.ModifierModel.TimeRateQ")
local TimeRateX		= require("sphere.models.ModifierModel.TimeRateX")
local AudioClip		= require("sphere.models.ModifierModel.AudioClip")
local NoScratch		= require("sphere.models.ModifierModel.NoScratch")
local Mirror		= require("sphere.models.ModifierModel.Mirror")
local Random		= require("sphere.models.ModifierModel.Random")
local BracketSwap	= require("sphere.models.ModifierModel.BracketSwap")
local NoLongNote	= require("sphere.models.ModifierModel.NoLongNote")
local NoMeasureLine	= require("sphere.models.ModifierModel.NoMeasureLine")
local FullLongNote	= require("sphere.models.ModifierModel.FullLongNote")
local ToOsu			= require("sphere.models.ModifierModel.ToOsu")
local AutoKeySound	= require("sphere.models.ModifierModel.AutoKeySound")
local MultiplePlay	= require("sphere.models.ModifierModel.MultiplePlay")
local MinLnLength	= require("sphere.models.ModifierModel.MinLnLength")
local Alternate		= require("sphere.models.ModifierModel.Alternate")
local MultiOverPlay	= require("sphere.models.ModifierModel.MultiOverPlay")
local Shift			= require("sphere.models.ModifierModel.Shift")

local ModifierModel = Class:new()

ModifierModel.modifiers = {
	AutoPlay,
	ProMode,
	AutoKeySound,
	SpeedMode,
	TimeRateQ,
	TimeRateX,
	AudioClip,
	WindUp,
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

ModifierModel.construct = function(self)
	self.modifierByName = {}
	self:createModifiers()
end

ModifierModel.load = function(self)
	local config = self.configModel:getConfig("modifier")
	self.config = config

	self.availableModifierItemIndex = 1
	self.modifierItemIndex = #config
end

ModifierModel.scrollAvailableModifier = function(self, direction)
	if not self.modifiers[self.availableModifierItemIndex + direction] then
		return
	end
	self.availableModifierItemIndex = self.availableModifierItemIndex + direction
end

ModifierModel.scrollModifier = function(self, direction)
	if not self.config[self.modifierItemIndex + direction] then
		return
	end
	self.modifierItemIndex = self.modifierItemIndex + direction
end

ModifierModel.createModifiers = function(self)
	local modifierByName = self.modifierByName
	for _, Modifier in ipairs(self.modifiers) do
		local modifier = Modifier:new()
		modifier.modifierModel = self
		modifierByName[modifier.name] = modifier
	end
end

ModifierModel.add = function(self, Modifier, index)
	local modifierConfig = Modifier:getDefaultConfig()
	local config = self.config
	if not index then
		table.insert(config, modifierConfig)
	else
		local maxIndex = math.max(#config, 1)
		index = math.min(math.max(index, 1), maxIndex)
		table.insert(config, index, modifierConfig)
	end
end

ModifierModel.remove = function(self, modifierConfig)
	for i, foundModifierConfig in ipairs(self.config) do
		if foundModifierConfig == modifierConfig then
			table.remove(self.config, i)
			return
		end
	end
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

ModifierModel.getModifier = function(self, modifierConfig)
	return self.modifierByName[modifierConfig.name]
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
		table.insert(t, modifier:getString(modifierConfig) .. modifier:getSubString(modifierConfig))
	end
	return table.concat(t, ",")
end

return ModifierModel
