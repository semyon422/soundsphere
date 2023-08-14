local rbtree = require("rbtree")
local ncbt = require("ncbt")
local class = require("class")

local NcbtContext = class()

function NcbtContext:load()
	self.onsets = nil

	self.onsetsDeltaDist = nil
	self.tempo = nil
	self.offset = nil
	self.bins = nil
	self.binsSize = nil
end

function NcbtContext:detect(soundData)
	self.duration = soundData:getDuration()

	local onsets = ncbt.onsets(soundData)

	local tree = rbtree.new()
	for _, time in ipairs(onsets) do
		tree:insert(time)
	end
	self.onsets = tree

	local out = ncbt.tempo_offset(onsets)

	self.onsetsDeltaDist = out.onsetsDeltaDist
	self.tempo = out.tempo
	self.offset = out.offset
	self.bins = out.bins
	self.binsSize = out.binsSize
end

function NcbtContext:apply(layerData)
	if not self.tempo then
		return
	end

	local ld = layerData
	ld:init()

	local beatDuration = 60 / self.tempo
	local beats = math.floor((self.duration - self.offset) / beatDuration)
	local lastOffset = beats * beatDuration + self.offset

	ld:getIntervalData(self.offset, beats)
	ld:getIntervalData(lastOffset, 1)
end

return NcbtContext
