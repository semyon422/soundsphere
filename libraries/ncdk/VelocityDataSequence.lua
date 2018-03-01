ncdk.VelocityDataSequence = {}
local VelocityDataSequence = ncdk.VelocityDataSequence

ncdk.VelocityDataSequence_metatable = {}
local VelocityDataSequence_metatable = ncdk.VelocityDataSequence_metatable
VelocityDataSequence_metatable.__index = VelocityDataSequence

VelocityDataSequence.new = function(self)
	local velocityDataSequence = {}
	
	velocityDataSequence.velocityDataCount = 0
	
	setmetatable(velocityDataSequence, VelocityDataSequence_metatable)
	
	return velocityDataSequence
end

VelocityDataSequence.addVelocityData = function(self, velocityData)
	table.insert(self, velocityData)
	self.velocityDataCount = self.velocityDataCount + 1
end

VelocityDataSequence.getVelocityData = function(self, velocityDataIndex)
	return self[velocityDataIndex]
end

VelocityDataSequence.getVelocityDataCount = function(self)
	return self.velocityDataCount
end

VelocityDataSequence.sort = function(self)
	table.sort(self, function(velocityData1, velocityData2)
		return velocityData1.timePoint < velocityData2.timePoint
	end)
end

VelocityDataSequence.getVelocityDataByTimePoint = function(self, timePoint)
	for currentVelocityDataIndex = 1, self:getVelocityDataCount() do
		local currentVelocityData = self:getVelocityData(currentVelocityDataIndex)
		if (currentVelocityDataIndex == self:getVelocityDataCount()) or
		   (currentVelocityDataIndex == 1 and timePoint < currentVelocityData.timePoint)
		then
			return currentVelocityData
		end
		
		local nextVelocityData = self:getVelocityData(currentVelocityDataIndex + 1)
		
		if timePoint >= currentVelocityData.timePoint and timePoint < nextVelocityData.timePoint then
			return currentVelocityData
		end
	end
end