local Class					= require("Class")
local GraphicalNoteFactory	= require("sphere.models.RhythmModel.GraphicEngine.GraphicalNoteFactory")

local NoteDrawer = Class:new()

NoteDrawer.load = function(self)
	self.noteData = {}

	self.layerData = self.graphicEngine.noteChart:requireLayerData(self.layerIndex)

	local graphicEngine = self.graphicEngine
	local timeEngine = self.graphicEngine.rhythmModel.timeEngine
	for noteDataIndex = 1, self.layerData:getNoteDataCount() do
		local noteData = self.layerData:getNoteData(noteDataIndex)

		if noteData.inputType == self.inputType and noteData.inputIndex == self.inputIndex then
			local graphicalNote = GraphicalNoteFactory:getNote(noteData)

			if graphicalNote then
				graphicalNote.noteDrawer = self
				graphicalNote.graphicEngine = graphicEngine
				graphicalNote.timeEngine = timeEngine
				graphicalNote.noteSkin = graphicEngine.noteSkin
				graphicalNote:init()
				if graphicEngine.noteSkin:check(graphicalNote) then
					table.insert(self.noteData, graphicalNote)
				end
			end
		end
	end

	self.currentTimePoint = self.layerData:getTimePoint()
	self.currentTimePoint.zeroClearVisualTime = 0
	self.currentVelocityDataIndex = 1

	table.sort(self.noteData, function(a, b)
		return a.startNoteData.timePoint.zeroClearVisualTime < b.startNoteData.timePoint.zeroClearVisualTime
	end)

	for index, graphicalNote in ipairs(self.noteData) do
		graphicalNote.index = index
	end

	self.startNoteIndex = 1
	self.endNoteIndex = 0
end

NoteDrawer.updateCurrentTime = function(self)
	local timeEngine = self.graphicEngine.rhythmModel.timeEngine
	self.currentTimePoint.absoluteTime = timeEngine.currentVisualTime - timeEngine.inputOffset

	self.currentVelocityData = self.layerData.spaceData:getVelocityData(self.currentVelocityDataIndex)
	self.nextVelocityData = self.layerData.spaceData:getVelocityData(self.currentVelocityDataIndex + 1)
	while true do
		if self.nextVelocityData and self.nextVelocityData.timePoint <= self.currentTimePoint then
			self.currentVelocityDataIndex = self.currentVelocityDataIndex + 1
			self.currentVelocityData = self.layerData.spaceData:getVelocityData(self.currentVelocityDataIndex)
			self.nextVelocityData = self.layerData.spaceData:getVelocityData(self.currentVelocityDataIndex + 1)
		else
			break
		end
	end
	self.currentTimePoint.velocityData = self.currentVelocityData
	self.currentTimePoint:computeZeroClearVisualTime()
end

NoteDrawer.update = function(self)
	self:updateCurrentTime()
	self.globalSpeed = self.currentTimePoint.velocityData.globalSpeed

	local noteData = self.noteData
	local note

	for i = self.startNoteIndex, self.endNoteIndex do
		noteData[i]:update()
	end

	for i = self.startNoteIndex, 2, -1 do
		note = noteData[i - 1]
		note:update()
		if not note:willDrawBeforeStart() and i == self.startNoteIndex then
			self.startNoteIndex = self.startNoteIndex - 1
		else
			break
		end
	end

	for i = self.endNoteIndex, #noteData - 1, 1 do
		note = noteData[i + 1]
		note:update()
		if not note:willDrawAfterEnd() and i == self.endNoteIndex then
			self.endNoteIndex = self.endNoteIndex + 1
		else
			break
		end
	end

	for i = self.startNoteIndex, self.endNoteIndex do
		note = noteData[i]
		if note:willDrawBeforeStart() then
			self.startNoteIndex = self.startNoteIndex + 1
		else
			break
		end
	end

	for i = self.endNoteIndex, self.startNoteIndex, -1 do
		note = noteData[i]
		if note:willDrawAfterEnd() then
			self.endNoteIndex = self.endNoteIndex - 1
		else
			break
		end
	end
end

return NoteDrawer
