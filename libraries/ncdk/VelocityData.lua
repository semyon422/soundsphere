ncdk.VelocityData = {}
local VelocityData = ncdk.VelocityData

ncdk.VelocityData_metatable = {}
local VelocityData_metatable = ncdk.VelocityData_metatable
VelocityData_metatable.__index = VelocityData

VelocityData.new = function(self, timePoint, currentSpeed, localSpeed, globalSpeed, visualEndTimePoint)
	local velocityData = {}
	
	velocityData.timePoint = timePoint
	velocityData.currentSpeed = currentSpeed or ncdk.Fraction:new(1)
	velocityData.localSpeed = localSpeed or ncdk.Fraction:new(1)
	velocityData.globalSpeed = globalSpeed or ncdk.Fraction:new(1)
	velocityData.visualEndTimePoint = visualEndTimePoint
	
	setmetatable(velocityData, VelocityData_metatable)
	
	return velocityData
end