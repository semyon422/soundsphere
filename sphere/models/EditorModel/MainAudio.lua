local Class = require("Class")

local MainAudio = Class:new()

MainAudio.load = function(self, path)
	self.soundData = nil
	self.offset = 0

	if love.filesystem.getInfo(path, "file") then
		self.soundData = love.sound.newSoundData(path)
	end
end

MainAudio.findOffset = function(self)
	for noteDatas in self.editorModel.noteChart:getInputIterator() do
		for _, noteData in ipairs(noteDatas) do
			if noteData.stream and noteData.streamOffset then
				self.offset = noteData.streamOffset
				return
			end
		end
	end
end

return MainAudio
