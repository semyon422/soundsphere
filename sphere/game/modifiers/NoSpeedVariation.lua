local Modifier = require("sphere.game.modifiers.Modifier")
local Fraction = require("ncdk.Fraction")

local NoSpeedVariation = Modifier:new()

NoSpeedVariation.name = "NoSpeedVariation"

local fractionOne = Fraction:new(1)
NoSpeedVariation.apply = function(self)
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

return NoSpeedVariation
