local Class			= require("Class")
local InputMode			= require("ncdk.InputMode")

local AutoKeySound	= require("sphere.models.ModifierModel.AutoKeySound")
local SpeedMode		= require("sphere.models.ModifierModel.SpeedMode")
local TimeRateQ		= require("sphere.models.ModifierModel.TimeRateQ")
local TimeRateX		= require("sphere.models.ModifierModel.TimeRateX")
local WindUp		= require("sphere.models.ModifierModel.WindUp")
local NoScratch		= require("sphere.models.ModifierModel.NoScratch")
local NoLongNote	= require("sphere.models.ModifierModel.NoLongNote")
local Automap		= require("sphere.models.ModifierModel.Automap")
local MultiplePlay	= require("sphere.models.ModifierModel.MultiplePlay")
local MinLnLength	= require("sphere.models.ModifierModel.MinLnLength")
local Alternate		= require("sphere.models.ModifierModel.Alternate")
local Alternate2		= require("sphere.models.ModifierModel.Alternate2")
local MultiOverPlay	= require("sphere.models.ModifierModel.MultiOverPlay")
local Shift			= require("sphere.models.ModifierModel.Shift")
local Mirror		= require("sphere.models.ModifierModel.Mirror")
local Random		= require("sphere.models.ModifierModel.Random")
local BracketSwap	= require("sphere.models.ModifierModel.BracketSwap")
local FullLongNote	= require("sphere.models.ModifierModel.FullLongNote")
local LessChord	= require("sphere.models.ModifierModel.LessChord")
local MaxChordSize	= require("sphere.models.ModifierModel.MaxChordSize")

local ModifierModel = Class:new()

local Modifiers = {
	AutoKeySound,
	SpeedMode,
	TimeRateQ,
	TimeRateX,
	WindUp,
	NoScratch,
	NoLongNote,
	Automap,
	MultiplePlay,
	MultiOverPlay,
	Alternate,
	Alternate2,
	Shift,
	Mirror,
	Random,
	BracketSwap,
	LessChord,
	MaxChordSize,
	FullLongNote,
	MinLnLength,
}

local ModifierId = {
	-- [AutoPlay] = 0,
	-- [ProMode] = 1,
	[AutoKeySound] = 2,
	[SpeedMode] = 3,
	[TimeRateQ] = 4,
	[TimeRateX] = 5,
	[WindUp] = 6,
	-- [AudioClip] = 7,
	[NoScratch] = 8,
	[NoLongNote] = 9,
	-- [NoMeasureLine] = 10,
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
	-- [ToOsu] = 21,
	[Alternate2] = 22,
	[LessChord] = 23,
	[MaxChordSize] = 24,
}

local OneUseModifiers = {
	AutoKeySound,
	SpeedMode,
	TimeRateQ,
	TimeRateX,
	WindUp,
	NoScratch,
	NoLongNote,
}

ModifierModel.construct = function(self)
	self.modifiers = {}
	self.oneUseModifiers = {}
	self.modifierByName = {}
	self.modifierById = {}
	self:createModifiers()
	self.availableModifierItemIndex = 1
end

ModifierModel.isChanged = function(self)
	local changed = self.changed
	self.changed = false
	return changed
end

ModifierModel.setConfig = function(self, config)
	self.config = config
	self.modifierItemIndex = math.min(math.max(self.modifierItemIndex or (#config + 1), 1), #config + 1)
	self.changed = true
	self.state = {
		timeRate = 1,
		inputMode = InputMode:new(),
	}
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
	modifier = modifier or self.modifiers[self.availableModifierItemIndex]
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
	self.changed = true
end

ModifierModel.remove = function(self, modifierConfig)
	modifierConfig = modifierConfig or self.config[self.modifierItemIndex]
	if not modifierConfig then
		return
	end
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
	self.changed = true
end

ModifierModel.setModifierValue = function(self, modifierConfig, value)
	modifierConfig = modifierConfig or self.config[self.modifierItemIndex]
	if not modifierConfig then
		return
	end
	local modifier = self:getModifier(modifierConfig)
	modifier:setValue(modifierConfig, value)
	self.changed = true
end

ModifierModel.increaseModifierValue = function(self, modifierConfig, delta)
	modifierConfig = modifierConfig or self.config[self.modifierItemIndex]
	if not modifierConfig then
		return
	end
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
	self.changed = true
end

ModifierModel.apply = function(self, noteChart)
	for _, modifierConfig in ipairs(self.config) do
		local modifier = self:getModifier(modifierConfig)
		if modifier then
			modifier.noteChart = noteChart
			modifier:apply(modifierConfig)
		end
	end
end

ModifierModel.applyMeta = function(self, state)
	self.state = state
	for _, modifierConfig in ipairs(self.config) do
		local modifier = self:getModifier(modifierConfig)
		if modifier then
			modifier:applyMeta(modifierConfig, state)
		end
	end
end

ModifierModel.getString = function(self, config)
	config = config or self.config
	local t = {}
	for _, modifierConfig in ipairs(config) do
		local modifier = self:getModifier(modifierConfig)
		if modifier then
			local modifierString = ""
			modifierString = modifierString .. (modifier:getString(modifierConfig) or "")
			modifierString = modifierString .. (modifier:getSubString(modifierConfig) or "")
			if #modifierString > 0 then
				table.insert(t, modifierString)
			end
		end
	end
	return table.concat(t, " ")
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
			if type(modifierConfig.value) == "number" and type(modifier.defaultValue) == "string" then
				modifierConfig.value = modifier:fromIndexValue(modifierConfig.value)
			end
		end
	end
end

return ModifierModel
