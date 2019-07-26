local Modifier = require("sphere.game.ModifierManager.Modifier")
local Fraction = require("ncdk.Fraction")

local CMod = Modifier:new()

CMod.name = "CMod"

local fractionOne = Fraction:new(1)
CMod.apply = function(self)
	local noteChart = self.sequence.noteChart
	
	for layerIndex in noteChart:getLayerDataIndexIterator() do
		local layerData = noteChart:requireLayerData(layerIndex)
		
		local velocityDataSequence = layerData.spaceData.velocityDataSequence
		for velocityDataIndex = 1, velocityDataSequence:getVelocityDataCount() do
			local velocityData = velocityDataSequence:getVelocityData(velocityDataIndex)
			
			velocityData.currentSpeed = fractionOne
			velocityData.localSpeed = fractionOne
			velocityData.globalSpeed = fractionOne
		end
	end
	
	noteChart:compute()
end

return CMod
