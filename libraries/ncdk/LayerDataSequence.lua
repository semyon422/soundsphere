ncdk.LayerDataSequence = {}
local LayerDataSequence = ncdk.LayerDataSequence

ncdk.LayerDataSequence_metatable = {}
local LayerDataSequence_metatable = ncdk.LayerDataSequence_metatable
LayerDataSequence_metatable.__index = LayerDataSequence

LayerDataSequence.new = function(self)
	local layerDataSequence = {}
	
	layerDataSequence.layerDataCount = 0
	
	layerDataSequence.layerDataIndexes = {}
	
	layerDataSequence.columnExisting = {}
	layerDataSequence.columnIndexes = {}
	
	setmetatable(layerDataSequence, LayerDataSequence_metatable)
	
	return layerDataSequence
end

LayerDataSequence.getLayerData = function(self, layerDataIndex)
	return self[layerDataIndex]
end

LayerDataSequence.requireLayerData = function(self, layerDataIndex)
	if not self[layerDataIndex] then
		self[layerDataIndex] = ncdk.LayerData:new()
		self[layerDataIndex].layerDataSequence = self
		
		self.layerDataCount = self.layerDataCount + 1
		table.insert(self.layerDataIndexes, layerDataIndex)
	end
	
	return self[layerDataIndex]
end

LayerDataSequence.getLayerDataIndexIterator = function(self)
	local counter = 1
	
	return function()
		local layerDataIndex = self.layerDataIndexes[counter]
		
		counter = counter + 1
		
		return layerDataIndex
	end
end

LayerDataSequence.getColumnIndexIteraator = function(self)
	local counter = 1
	
	return function()
		local columnIndex = self.columnIndexes[counter]
		
		counter = counter + 1
		
		return columnIndex
	end
end