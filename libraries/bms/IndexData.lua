bms.IndexData = {}
local IndexData = bms.IndexData

bms.IndexData_metatable = {}
local IndexData_metatable = bms.IndexData_metatable
IndexData_metatable.__index = IndexData

IndexData.new = function(self, measureTimeOffset, value)
	local indexData = {}
	
	indexData.measureTimeOffset = measureTimeOffset
	indexData.value = value
	
	setmetatable(indexData, IndexData_metatable)
	
	return indexData
end