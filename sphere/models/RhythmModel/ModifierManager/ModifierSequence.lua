local Class			= require("aqua.util.Class")
local json			= require("json")

local AutoPlay		= require("sphere.models.RhythmModel.ModifierManager.AutoPlay")
local Automap		= require("sphere.models.RhythmModel.ModifierManager.Automap")
local ProMode		= require("sphere.models.RhythmModel.ModifierManager.ProMode")
local WindUp		= require("sphere.models.RhythmModel.ModifierManager.WindUp")
local SpeedMode		= require("sphere.models.RhythmModel.ModifierManager.SpeedMode")
local TimeRateQ		= require("sphere.models.RhythmModel.ModifierManager.TimeRateQ")
local TimeRateX		= require("sphere.models.RhythmModel.ModifierManager.TimeRateX")
local NoScratch		= require("sphere.models.RhythmModel.ModifierManager.NoScratch")
local Mirror		= require("sphere.models.RhythmModel.ModifierManager.Mirror")
local Random		= require("sphere.models.RhythmModel.ModifierManager.Random")
local BracketSwap	= require("sphere.models.RhythmModel.ModifierManager.BracketSwap")
local NoLongNote	= require("sphere.models.RhythmModel.ModifierManager.NoLongNote")
local NoMeasureLine	= require("sphere.models.RhythmModel.ModifierManager.NoMeasureLine")
local FullLongNote	= require("sphere.models.RhythmModel.ModifierManager.FullLongNote")
local ToOsu			= require("sphere.models.RhythmModel.ModifierManager.ToOsu")
local AutoKeySound	= require("sphere.models.RhythmModel.ModifierManager.AutoKeySound")
local MultiplePlay	= require("sphere.models.RhythmModel.ModifierManager.MultiplePlay")

local ModifierSequence = Class:new()

ModifierSequence.modifiers = {
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
	SpeedMode,
	TimeRateQ,
	TimeRateX,
	WindUp,
	NoScratch,
	NoLongNote,
	NoMeasureLine,
	AutoKeySound,
	ToOsu
}

ModifierSequence.path = "userdata/modifiers.json"

ModifierSequence.load = function(self)
	if love.filesystem.exists(self.path) then
		local file = io.open(self.path, "r")
		local jsonObject = json.decode(file:read("*all"))
		file:close()
		
		self.sequence:fromJson(jsonObject)
	end
end

ModifierSequence.unload = function(self)
	local file = io.open(self.path, "w")
	file:write(self.sequence:toJson())
	return file:close()
end

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
			-- modifier:apply()
		end
	end
end

ModifierSequence.update = function(self)
	for _, modifier in ipairs(self:getEnabledModifiers()) do
		-- modifier:update()
	end
end

ModifierSequence.receive = function(self, event)
	for _, modifier in ipairs(self:getEnabledModifiers()) do
		-- modifier:receive(event)
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

ModifierSequence.toTable = function(self)
	return json.decode(self:toJson())
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
