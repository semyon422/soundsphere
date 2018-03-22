bms.ChannelDataSequence = {}
local ChannelDataSequence = bms.ChannelDataSequence

bms.ChannelDataSequence_metatable = {}
local ChannelDataSequence_metatable = bms.ChannelDataSequence_metatable
ChannelDataSequence_metatable.__index = ChannelDataSequence

ChannelDataSequence.new = function(self)
	local channelDataSequence = {}
	
	channelDataSequence.data = {}
	
	setmetatable(channelDataSequence, ChannelDataSequence_metatable)
	
	return channelDataSequence
end

ChannelDataSequence.requireChannelData = function(self, measureIndex, channelIndex)
	self.data[measureIndex] = self.data[measureIndex] or {}
	self.data[measureIndex][channelIndex] = self.data[measureIndex][channelIndex] or bms.ChannelData:new()
	
	self.data[measureIndex][channelIndex].compound = bms.ChannelEnum[channelIndex].name ~= "BGM"
	self.data[measureIndex][channelIndex].oneDecimal = bms.ChannelEnum[channelIndex].name == "Signature"
	
	return self.data[measureIndex][channelIndex]
end