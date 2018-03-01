ncdk.StopData = {}
local StopData = ncdk.StopData

ncdk.StopData_metatable = {}
local StopData_metatable = ncdk.StopData_metatable
StopData_metatable.__index = StopData

StopData.new = function(self, measureTime, measureDuration)
	local stopData = {}
	
	stopData.measureTime = measureTime
	stopData.measureDuration = measureDuration
	
	setmetatable(stopData, StopData_metatable)
	
	return stopData
end