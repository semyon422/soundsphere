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
	for _, modifier in ipairs(self.list) do
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
