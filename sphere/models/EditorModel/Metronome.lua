local Class = require("Class")
local audio = require("audio")

local Metronome = Class:new()

local samplePath = "resources/metronome.ogg"

Metronome.load = function(self)
	self.fileData = love.filesystem.newFileData(samplePath)
	self.soundData = audio.SoundData(self.fileData:getFFIPointer(), self.fileData:getSize())
	self.source = audio.newSource(self.soundData)

	self.nextTime = math.huge
end

Metronome.unload = function(self)
	self.source:release()
	self.soundData:release()
end

Metronome.getNextTime = function(self)
	local editorModel = self.editorModel
	local timePoint = editorModel.timePoint
	local ld = editorModel.layerData
	local currentTime = editorModel.timer:getTime()

	if timePoint:tonumber() > currentTime then
		return timePoint:tonumber()
	end

	local id, t = editorModel.scroller:getNextSnapIntervalTime(timePoint, 1)

	local nextTimePoint = ld:getDynamicTimePoint(id, t)
	local nextTime = nextTimePoint:tonumber()

	return nextTime
end

Metronome.update = function(self)
	local editorModel = self.editorModel

	local currentTime = editorModel.timer:getTime()
	if currentTime >= self.nextTime then
		local source = self.source
		source:stop()
		source:setVolume(self.volume.master * self.volume.metronome)
		source:play()
	end

	self.nextTime = self:getNextTime()
end

return Metronome
