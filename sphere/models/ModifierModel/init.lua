local Class			= require("aqua.util.Class")

local AutoPlay		= require("sphere.models.ModifierModel.AutoPlay")
local Automap		= require("sphere.models.ModifierModel.Automap")
local ProMode		= require("sphere.models.ModifierModel.ProMode")
local WindUp		= require("sphere.models.ModifierModel.WindUp")
local SpeedMode		= require("sphere.models.ModifierModel.SpeedMode")
local TimeRateQ		= require("sphere.models.ModifierModel.TimeRateQ")
local TimeRateX		= require("sphere.models.ModifierModel.TimeRateX")
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

local ModifierModel = Class:new()

ModifierModel.modifiers = {
	AutoPlay,
	ProMode,
	AutoKeySound,
	SpeedMode,
	TimeRateQ,
	TimeRateX,
	WindUp,
	NoScratch,
	NoLongNote,
	NoMeasureLine,
	Automap,
	MultiplePlay,
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

ModifierModel.createModifiers = function(self)
	local modifierByName = self.modifierByName
	for _, Modifier in ipairs(self.modifiers) do
		local modifier = Modifier:new()
		modifier.modifierModel = self
		modifierByName[modifier.name] = modifier
	end
end

ModifierModel.add = function(self, modifierConfig)
	table.insert(self.config, modifierConfig)
end

ModifierModel.remove = function(self, modifierConfig)
	for i, foundModifierConfig in ipairs(self.config) do
		if foundModifierConfig == modifierConfig then
			table.remove(self.config, i)
			return
		end
	end
end

ModifierModel.apply = function(self, modifierType)
	local modifierByName = self.modifierByName
	for _, modifierConfig in ipairs(self.config) do
		local modifier = modifierByName[modifierConfig.name]
		if modifier.type == modifierType then
			modifier.config = modifierConfig
			modifier.noteChartModel = self.noteChartModel
			modifier.rhythmModel = self.rhythmModel
			modifier.difficultyModel = self.difficultyModel
			modifier.scoreModel = self.scoreModel
			modifier:apply()
		end
	end
end

ModifierModel.update = function(self)
	local modifierByName = self.modifierByName
	for _, modifierConfig in ipairs(self.config) do
		local modifier = modifierByName[modifierConfig.name]
		modifier.config = modifierConfig
		modifier:update()
	end
end

ModifierModel.receive = function(self, event)
	local modifierByName = self.modifierByName
	for _, modifierConfig in ipairs(self.config) do
		local modifier = modifierByName[modifierConfig.name]
		modifier.config = modifierConfig
		modifier:receive(event)
	end
end

return ModifierModel
