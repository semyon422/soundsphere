local Class = require("aqua.util.Class")

local ModifierSequence = Class:new()

ModifierSequence.construct = function(self)
	self.list = {}
end

ModifierSequence.add = function(self, modifier)
	modifier.sequence = self
	self.list[#self.list + 1] = modifier
end

ModifierSequence.remove = function(self)
	if #self.list > 0 then
		self.list[#self.list] = nil
	end
end

ModifierSequence.apply = function(self)
	local engine = self.manager.engine
	local noteChart = self.manager.noteChart
	local noteSkin = self.manager.noteSkin
	local playField = self.manager.playField
	
	for _, modifier in ipairs(self.list) do
		modifier.engine = engine
		modifier.noteChart = noteChart
		modifier.noteSkin = noteSkin
		modifier.playField = playField
		modifier:apply()
	end
end

ModifierSequence.tostring = function(self)
	local out = {}
	
	for _, modifier in ipairs(self.list) do
		out[#out + 1] = modifier:tostring()
	end
	
	return table.concat(out, " | ")
end

return ModifierSequence
