local Class = require("aqua.util.Class")

local ModifierSequence = Class:new()

ModifierSequence.add = function(self, modifier)
	self.modifiers = self.modifiers or {}
	modifier.sequence = self
	table.insert(self.modifiers, modifier)
end

ModifierSequence.apply = function(self)
	for _, modifier in ipairs(self.modifiers) do
		modifier:apply()
	end
end

return ModifierSequence
