ncdk.VelocityDataImporter = {}
local VelocityDataImporter = ncdk.VelocityDataImporter

ncdk.VelocityDataImporter_metatable = {}
local VelocityDataImporter_metatable = ncdk.VelocityDataImporter_metatable
VelocityDataImporter_metatable.__index = VelocityDataImporter

VelocityDataImporter.new = function(self, lineTable)
	local velocityDataImporter = {}
	
	velocityDataImporter.lineTable = lineTable
	
	setmetatable(velocityDataImporter, VelocityDataImporter_metatable)
	
	return velocityDataImporter
end

VelocityDataImporter.DataEnum = {
	measureTime = 3,
	side = 4,
	currentSpeed = 5,
	localSpeed = 6,
	globalSpeed = 7,
	visualEndTimePoint = 8
}

VelocityDataImporter.getVelocityData = function(self, timingData)
	local measureTime = ncdk.Fraction:new():fromString(self.lineTable[self.DataEnum.measureTime])
	local side = tonumber(self.lineTable[self.DataEnum.side])
	local timePoint = timingData:getTimePoint(measureTime, side)
	
	local visualEndMeasureTime, visualEndTimePoint
	if self.lineTable[self.DataEnum.visualEndTimePoint] then
		visualEndMeasureTime = ncdk.Fraction:new():fromString(self.lineTable[self.DataEnum.visualEndTimePoint])
		visualEndTimePoint = timingData:getTimePoint(visualEndMeasureTime, side)
	end
	
	local velocityData = ncdk.VelocityData:new(timePoint,
		ncdk.Fraction:new():fromString(self.lineTable[self.DataEnum.currentSpeed]),
		ncdk.Fraction:new():fromString(self.lineTable[self.DataEnum.localSpeed]),
		ncdk.Fraction:new():fromString(self.lineTable[self.DataEnum.globalSpeed]),
		visualEndTimePoint
	)
	
	
	return velocityData
end