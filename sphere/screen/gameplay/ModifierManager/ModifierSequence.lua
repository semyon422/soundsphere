local Class			= require("aqua.util.Class")

local AutoPlay		= require("sphere.screen.gameplay.ModifierManager.AutoPlay")
local Automap		= require("sphere.screen.gameplay.ModifierManager.Automap")
local ProMode		= require("sphere.screen.gameplay.ModifierManager.ProMode")
local SetInput		= require("sphere.screen.gameplay.ModifierManager.SetInput")
local Pitch			= require("sphere.screen.gameplay.ModifierManager.Pitch")
local TimeRate		= require("sphere.screen.gameplay.ModifierManager.TimeRate")
local Mirror		= require("sphere.screen.gameplay.ModifierManager.Mirror")
local NoLongNote	= require("sphere.screen.gameplay.ModifierManager.NoLongNote")
local NoMeasureLine	= require("sphere.screen.gameplay.ModifierManager.NoMeasureLine")
local CMod			= require("sphere.screen.gameplay.ModifierManager.CMod")
local FullLongNote	= require("sphere.screen.gameplay.ModifierManager.FullLongNote")
local ToOsu			= require("sphere.screen.gameplay.ModifierManager.ToOsu")

local ModifierSequence = Class:new()

ModifierSequence.construct = function(self)
	self.sequential = {}
	self.inconsequential = {}
	
	self:addInconsequential()
end

ModifierSequence.addInconsequential = function(self)
	local list = self.inconsequential
	
	local autoPlay = AutoPlay:new()
	autoPlay.sequence = self
	list[#list + 1] = autoPlay
	self[AutoPlay] = autoPlay
	
	local proMode = ProMode:new()
	proMode.sequence = self
	list[#list + 1] = proMode
	self[ProMode] = proMode
	
	local setInput = SetInput:new()
	setInput.sequence = self
	list[#list + 1] = setInput
	self[SetInput] = setInput
	
	local pitch = Pitch:new()
	pitch.sequence = self
	list[#list + 1] = pitch
	self[Pitch] = pitch
	
	local timeRate = TimeRate:new()
	timeRate.sequence = self
	list[#list + 1] = timeRate
	self[TimeRate] = timeRate
	
	local mirror = Mirror:new()
	mirror.sequence = self
	list[#list + 1] = mirror
	self[Mirror] = mirror
	
	local noLongNote = NoLongNote:new()
	noLongNote.sequence = self
	list[#list + 1] = noLongNote
	self[NoLongNote] = noLongNote
	
	local noMeasureLine = NoMeasureLine:new()
	noMeasureLine.sequence = self
	list[#list + 1] = noMeasureLine
	self[NoMeasureLine] = noMeasureLine
	
	local cMod = CMod:new()
	cMod.sequence = self
	list[#list + 1] = cMod
	self[CMod] = cMod
	
	local toOsu = ToOsu:new()
	toOsu.sequence = self
	list[#list + 1] = toOsu
	self[ToOsu] = toOsu
end

ModifierSequence.add = function(self, Modifier)
	if Modifier.inconsequential then
		self[Modifier]:setValue(Modifier:getValue())
	elseif Modifier.sequential then
		local modifier = Modifier:new()
		modifier.sequence = self
		self.sequential[#self.sequential + 1] = modifier
	end
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

ModifierSequence.apply = function(self)
	for _, modifier in ipairs(self.inconsequential) do
		if not modifier.after and modifier:getValue() then
			modifier:apply()
		end
	end
	for _, modifier in ipairs(self.sequential) do
		modifier:apply()
	end
	for _, modifier in ipairs(self.inconsequential) do
		if modifier.after and modifier:getValue() then
			modifier:apply()
		end
	end
end

ModifierSequence.tostring = function(self)
	local out = {}
	
	for _, modifier in ipairs(self.inconsequential) do
		if not modifier.after and modifier:getValue() then
			out[#out + 1] = modifier:tostring()
		end
	end
	for _, modifier in ipairs(self.sequential) do
		out[#out + 1] = modifier:tostring()
	end
	for _, modifier in ipairs(self.inconsequential) do
		if modifier.after and modifier:getValue() then
			out[#out + 1] = modifier:tostring()
		end
	end
	
	return table.concat(out, ", ")
end

return ModifierSequence
