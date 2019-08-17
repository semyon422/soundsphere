local Modifier = require("sphere.screen.gameplay.ModifierManager.Modifier")
local Fraction = require("ncdk.Fraction")

local CMod = Modifier:new()

CMod.name = "CMod"

CMod.apply = function(self)
	local noteChart = self.noteChart
	
	for layerIndex in noteChart:getLayerDataIndexIterator() do
		local layerData = noteChart:requireLayerData(layerIndex)
		
		local velocityDataSequence = layerData.spaceData.velocityDataSequence
		for velocityDataIndex = 1, velocityDataSequence:getVelocityDataCount() do
			local velocityData = velocityDataSequence:getVelocityData(velocityDataIndex)
			
			velocityData.currentSpeed = 1
			velocityData.localSpeed = 1
			velocityData.globalSpeed = 1
		end
	end
	
	noteChart:compute()
end

return CMod
