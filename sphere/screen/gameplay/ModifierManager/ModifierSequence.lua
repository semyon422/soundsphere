local Class			= require("aqua.util.Class")

local AutoPlay		= require("sphere.screen.gameplay.ModifierManager.AutoPlay")
local Automap		= require("sphere.screen.gameplay.ModifierManager.Automap")
local ProMode		= require("sphere.screen.gameplay.ModifierManager.ProMode")
local WindUp		= require("sphere.screen.gameplay.ModifierManager.WindUp")
local SpeedMode		= require("sphere.screen.gameplay.ModifierManager.SpeedMode")
local TimeRateQ		= require("sphere.screen.gameplay.ModifierManager.TimeRateQ")
local TimeRateX		= require("sphere.screen.gameplay.ModifierManager.TimeRateX")
local NoScratch		= require("sphere.screen.gameplay.ModifierManager.NoScratch")
local Mirror		= require("sphere.screen.gameplay.ModifierManager.Mirror")
local NoLongNote	= require("sphere.screen.gameplay.ModifierManager.NoLongNote")
local NoMeasureLine	= require("sphere.screen.gameplay.ModifierManager.NoMeasureLine")
local FullLongNote	= require("sphere.screen.gameplay.ModifierManager.FullLongNote")
local ToOsu			= require("sphere.screen.gameplay.ModifierManager.ToOsu")
local AutoKeySound	= require("sphere.screen.gameplay.ModifierManager.AutoKeySound")
local DoublePlay	= require("sphere.screen.gameplay.ModifierManager.DoublePlay")

local ModifierSequence = Class:new()

ModifierSequence.modifiers = {
	AutoPlay,
	AutoKeySound,
	Automap,
	DoublePlay,
	ProMode,
	WindUp,
	SpeedMode,
	TimeRateQ,
	TimeRateX,
	NoScratch,
	Mirror,
	NoLongNote,
	NoMeasureLine,
	FullLongNote,
	ToOsu
}

ModifierSequence.construct = function(self)
	self.sequential = {}
	self.inconsequential = {}
	
	self:addInconsequential()
end

ModifierSequence.inconsequentialClassList = {
	AutoPlay,
	ProMode,
	WindUp,
	SpeedMode,
	TimeRateQ,
	TimeRateX,
	NoScratch,
	Mirror,
	NoLongNote,
	NoMeasureLine,
	AutoKeySound,
	DoublePlay,
	ToOsu
}

ModifierSequence.addInconsequential = function(self)
	local list = self.inconsequential
	
	for _, Modifier in ipairs(self.inconsequentialClassList) do
		local modifier = Modifier:new()
		modifier.sequence = self
		modifier.enabled = false
		modifier.Class = Modifier
		list[#list + 1] = modifier
		-- self[Modifier] = modifier
		if Modifier == TimeRateX or Modifier == TimeRateQ or Modifier == SpeedMode then
			modifier.enabled = true
		end
	end
end

ModifierSequence.get = function(self, Modifier)
	for _, modifier in ipairs(self.inconsequential) do
		if modifier.Class == Modifier then
			return modifier
		end
	end
end

ModifierSequence.add = function(self, Modifier)
	local modifier = Modifier:new()
	modifier.sequence = self
	modifier.Class = Modifier
	self.sequential[#self.sequential + 1] = modifier
	return modifier
end

ModifierSequence.remove = function(self, modifier)
	local list = self.sequential
	for i, listModifier in ipairs(list) do
		if listModifier == modifier then
			table.remove(list, i)
			return
		end
	end
end

ModifierSequence.getEnabledModifiers = function(self)
	local list = {}

	for _, modifier in ipairs(self.inconsequential) do
		if not modifier.after and modifier.enabled then
			list[#list + 1] = modifier
		end
	end
	for _, modifier in ipairs(self.sequential) do
		list[#list + 1] = modifier
	end
	for _, modifier in ipairs(self.inconsequential) do
		if modifier.after and modifier.enabled then
			list[#list + 1] = modifier
		end
	end

	return list
end

ModifierSequence.apply = function(self, modifierType)
	for _, modifier in ipairs(self:getEnabledModifiers()) do
		if modifier.type == modifierType then
			modifier:apply()
		end
	end
end

ModifierSequence.update = function(self)
	for _, modifier in ipairs(self:getEnabledModifiers()) do
		modifier:update()
	end
end

ModifierSequence.receive = function(self, event)
	for _, modifier in ipairs(self:getEnabledModifiers()) do
		modifier:receive(event)
	end
end

ModifierSequence.tostring = function(self)
	local out = {}
	
	for _, modifier in ipairs(self:getEnabledModifiers()) do
		out[#out + 1] = modifier:tostring()
	end
	
	return table.concat(out, ", ")
end

ModifierSequence.toJson = function(self)
	local out = {}
	
	for _, modifier in ipairs(self:getEnabledModifiers()) do
		out[#out + 1] = modifier:tojson()
	end
	
	return ("[%s]"):format(table.concat(out, ","))
end

ModifierSequence.fromJson = function(self, jsonObject)
	self:construct()

	for _, modifierData in ipairs(jsonObject) do
		for _, Modifier in ipairs(self.modifiers) do
			if modifierData.name == Modifier.name then
				local modifier
				if Modifier.inconsequential then
					modifier = self:get(Modifier)
					modifier.enabled = true
				elseif Modifier.sequential then
					modifier = self:add(Modifier)
				end
				
				if modifier.variableName then
					modifier[modifier.variableName] = modifierData[modifier.variableName]
				end
			end
		end
	end
end

return ModifierSequence
