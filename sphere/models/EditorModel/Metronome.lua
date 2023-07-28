local Class = require("Class")
local audio = require("audio")

local Metronome = Class:new()

local samplePath = "resources/metronome.ogg"

Metronome.load = function(self)
	self.fileData = love.filesystem.newFileData(samplePath)
	self.soundData = audio.SoundData(self.fileData:getFFIPointer(), self.fileData:getSize())
	self.source = audio.newSource(self.soundData)

	self.nextTime = math.huge
	self.isNextBeat = false
end

Metronome.unload = function(self)
	self.source:release()
	self.soundData:release()
end

Metronome.updateNextTime = function(self)
	local editorModel = self.editorModel
	local timePoint = editorModel.timePoint
	local ld = editorModel.layerData
	local currentTime = editorModel.timer:getTime()

	if timePoint:tonumber() > currentTime then
		return timePoint:tonumber()
	end

	local id, t = editorModel.scroller:getNextSnapIntervalTime(timePoint, 1)

	local nextTimePoint = ld:getDynamicTimePoint(id, t)

	self.nextTime = nextTimePoint:tonumber()
	self.isNextBeat = (nextTimePoint.time % 1):tonumber() == 0
end

Metronome.update = function(self)
	local editorModel = self.editorModel

	local currentTime = editorModel.timer:getTime()
	if currentTime >= self.nextTime then
		local source = self.source
		source:stop()
		source:setVolume(self.volume.master * self.volume.metronome)
		-- source:setRate(2099 / 2645)
		-- if self.isNextBeat then
			-- source:setRate(1)
		-- end
		print("play")
		source:play()
	end

	self:updateNextTime()
end

return Metronome
