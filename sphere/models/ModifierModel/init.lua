local Class			= require("aqua.util.Class")
local json			= require("json")

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
	self.sequential = {}
	self.inconsequential = {}

	self:addInconsequential()
end

ModifierModel.inconsequentialClassList = {
	AutoPlay,
	ProMode,
	SpeedMode,
	TimeRateQ,
	TimeRateX,
	AudioClip,
	WindUp,
	NoScratch,
	NoLongNote,
	NoMeasureLine,
	AutoKeySound,
	ToOsu
}

ModifierModel.path = "userdata/modifiers.json"

ModifierModel.load = function(self)
	local info = love.filesystem.getInfo(self.path)
	if info and info.size ~= 0 then
		local contents = love.filesystem.read(self.path)
		local jsonObject = json.decode(contents)

        self:fromTable(jsonObject)
	end
end

ModifierModel.unload = function(self)
	love.filesystem.write(self.path, self:toJson())
end

ModifierModel.addInconsequential = function(self)
	local list = self.inconsequential

	for _, Modifier in ipairs(self.inconsequentialClassList) do
		local modifier = Modifier:new()
		modifier.modifierModel = self
		modifier.enabled = false
		modifier.Class = Modifier
		list[#list + 1] = modifier
		if
			Modifier == TimeRateX or
			Modifier == TimeRateQ or
			Modifier == SpeedMode or
			Modifier == AudioClip
		then
			modifier.enabled = true
		end
	end
end

ModifierModel.get = function(self, Modifier)
	for _, modifier in ipairs(self.inconsequential) do
		if modifier.Class == Modifier then
			return modifier
		end
	end
end

ModifierModel.add = function(self, Modifier)
	local modifier = Modifier:new()
	modifier.modifierModel = self
	modifier.Class = Modifier
	self.sequential[#self.sequential + 1] = modifier
	return modifier
end

ModifierModel.remove = function(self, modifier)
	local list = self.sequential
	for i, listModifier in ipairs(list) do
		if listModifier == modifier then
			table.remove(list, i)
			return
		end
	end
end

ModifierModel.getEnabledModifiers = function(self)
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

ModifierModel.apply = function(self, modifierType)
	for _, modifier in ipairs(self:getEnabledModifiers()) do
		if modifier.type == modifierType then
			modifier.noteChartModel = self.noteChartModel
			modifier.rhythmModel = self.rhythmModel
			modifier.difficultyModel = self.difficultyModel
			modifier.scoreModel = self.scoreModel
			modifier:apply()
		end
	end
end

ModifierModel.update = function(self)
	for _, modifier in ipairs(self:getEnabledModifiers()) do
		modifier:update()
	end
end

ModifierModel.receive = function(self, event)
	for _, modifier in ipairs(self:getEnabledModifiers()) do
		modifier:receive(event)
	end
end

ModifierModel.getString = function(self)
	local out = {}

	for _, modifier in ipairs(self:getEnabledModifiers()) do
		local s = modifier:tostring()
		if s then
			out[#out + 1] = s
		end
	end

	return table.concat(out, ", ")
end

-- TODO: rework this awful approach
ModifierModel.toJson = function(self)
	local out = {}

	for _, modifier in ipairs(self:getEnabledModifiers()) do
		out[#out + 1] = modifier:tojson()
	end

	return ("[%s]"):format(table.concat(out, ","))
end

ModifierModel.toTable = function(self)
	return json.decode(self:toJson())
end

ModifierModel.fromTable = function(self, modifiersTable)
	self:construct()

	for _, modifierData in ipairs(modifiersTable) do
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

return ModifierModel
