local ModifierSequence	= require("sphere.screen.gameplay.ModifierManager.ModifierSequence")
local json				= require("json")

local ModifierManager = {}

ModifierManager.path = "userdata/modifiers.json"

ModifierManager.init = function(self)
	self.sequence = ModifierSequence:new()
	self.sequence.manager = self
end

ModifierManager.load = function(self)
	if love.filesystem.exists(self.path) then
		local file = io.open(self.path, "r")
		local jsonObject = json.decode(file:read("*all"))
		file:close()
		
		self.sequence:fromJson(jsonObject)
	end
end

ModifierManager.unload = function(self)
	local file = io.open(self.path, "w")
	file:write(self.sequence:toJson())
	return file:close()
end

ModifierManager.apply = function(self)
	return self.sequence:apply()
end

ModifierManager.update = function(self)
	return self.sequence:update()
end

ModifierManager.getSequence = function(self)
	return self.sequence
end

return ModifierManager
