local Class			= require("aqua.util.Class")
local FileManager	= require("sphere.filesystem.FileManager")
local ImageNote		= require("sphere.screen.gameplay.BMSBGA.ImageNote")
local VideoNote		= require("sphere.screen.gameplay.BMSBGA.VideoNote")

local NoteHandler = Class:new()

NoteHandler.load = function(self)
	self.noteData = {}
	
	for layerDataIndex in self.engine.noteChart:getLayerDataIndexIterator() do
		local layerData = self.engine.noteChart:requireLayerData(layerDataIndex)
		for noteDataIndex = 1, layerData:getNoteDataCount() do
			local noteData = layerData:getNoteData(noteDataIndex)
			
			if noteData.inputType == "bmsbga" and noteData.inputIndex == self.inputIndex then
				local logicalNote
				
				local fileType
				local images = noteData.images[1] and noteData.images[1][1]
				if images then
					fileType = FileManager:getType(images)
				end
				if fileType == "image" then
					logicalNote = ImageNote:new({
						noteData = noteData,
						images = noteData.images,
						noteType = "ImageNote"
					})
				elseif fileType == "video" then
					logicalNote = VideoNote:new({
						noteData = noteData,
						images = noteData.images,
						noteType = "VideoNote"
					})
				end
				
				if logicalNote then
					logicalNote.noteHandler = self
					logicalNote.bga = self.bga
					logicalNote.engine = self.engine
					table.insert(self.noteData, logicalNote)
				end
			end
		end
	end
	
	table.sort(self.noteData, function(a, b)
		return a.noteData.timePoint < b.noteData.timePoint
	end)

	for index, logicalNote in ipairs(self.noteData) do
		logicalNote.index = index
	end
	
	self.startNoteIndex = 1
	self.currentNote = self.noteData[1]
	if self.currentNote then
		self.currentNote:load()
	end
end

NoteHandler.unload = function(self)

end

NoteHandler.update = function(self)
	if not self.currentNote then return end
	
	self.currentNote:update()
end

NoteHandler.draw = function(self)
	if not self.currentNote then return end
	
	self.currentNote:draw()
end

NoteHandler.setTimeRate = function(self, timeRate)
	self.timeRate = timeRate
	
	if not self.currentNote then return end
	
	self.currentNote:setTimeRate(timeRate)
end

NoteHandler.pause = function(self)
	if not self.currentNote then return end
	
	self.currentNote:pause()
end

NoteHandler.play = function(self)
	if not self.currentNote then return end
	
	self.currentNote:play()
end

NoteHandler.receive = function(self, event)
	if not self.currentNote then return end
	
	if event.name == "resize" then
		self.currentNote:reload()
	end
end

return NoteHandler
