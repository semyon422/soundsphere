bms.ChannelData = {}
local ChannelData = bms.ChannelData

bms.ChannelData_metatable = {}
local ChannelData_metatable = bms.ChannelData_metatable
ChannelData_metatable.__index = ChannelData

ChannelData.new = function(self)
	local channelData = {}
	
	channelData.indexDatas = {}
	
	setmetatable(channelData, ChannelData_metatable)
	
	return channelData
end

ChannelData.getDataIndex = function(self, measureTimeOffset)
	for indexDataIndex, indexData in ipairs(self.indexDatas) do
		if indexData.measureTimeOffset == measureTimeOffset then
			return indexData, indexDataIndex
		end
	end
end

ChannelData.addIndexData = function(self, indexDataString)
	if self.oneDecimal then
		self.value = tonumber((indexDataString:gsub(",", ".")))
		return
	end
	
	if #indexDataString % 2 ~= 0 then
		print("warning")
		indexDataString = indexDataString:sub(1, -2)
	end
	
	for indexDataIndex = 1, #indexDataString / 2 do
		local value = indexDataString:sub(2 * indexDataIndex - 1, 2 * indexDataIndex)
		if value ~= "00" then
			local measureTimeOffset = ncdk.Fraction:new(indexDataIndex - 1, #indexDataString / 2)
			local indexData = bms.IndexData:new(measureTimeOffset, value)
			local existingIndexData, existingIndexDataIndex = self:getDataIndex(measureTimeOffset)
			if self.compound and existingIndexData then
				self.indexDatas[existingIndexDataIndex] = indexData
			else
				table.insert(self.indexDatas, indexData)
			end
		end
	end
end