local Class					= require("Class")
local GraphicalNoteFactory	= require("sphere.models.RhythmModel.GraphicEngine.GraphicalNoteFactory")

local NoteDrawer = Class:new()

NoteDrawer.load = function(self)
	local graphicEngine = self.graphicEngine
	local timeEngine = graphicEngine.rhythmModel.timeEngine
	self.layerData = graphicEngine.noteChart:requireLayerData(self.layerIndex)

	self.currentTimePoint = self.layerData:getTimePoint()
	self.currentTimePoint.zeroClearVisualTime = 0
	self.currentVelocityDataIndex = 1

	self.notes = {}
	for noteDataIndex = 1, self.layerData:getNoteDataCount() do
		local noteData = self.layerData:getNoteData(noteDataIndex)

		if noteData.inputType == self.inputType and noteData.inputIndex == self.inputIndex then
			local graphicalNote = GraphicalNoteFactory:getNote(noteData)

			if graphicalNote then
				graphicalNote.currentTimePoint = self.currentTimePoint
				graphicalNote.graphicEngine = graphicEngine
				graphicalNote.timeEngine = timeEngine
				graphicalNote.logicalNote = graphicEngine:getLogicalNote(graphicalNote.startNoteData)
				if graphicEngine.noteSkin:check(graphicalNote) then
					table.insert(self.notes, graphicalNote)
				end
			end
		end
	end

	table.sort(self.notes, function(a, b)
		return a.startNoteData.timePoint.zeroClearVisualTime < b.startNoteData.timePoint.zeroClearVisualTime
	end)

	for index, graphicalNote in ipairs(self.notes) do
		graphicalNote.nextNote = self.notes[index + 1]
	end

	self.startNoteIndex = 1
	self.endNoteIndex = 0
end

NoteDrawer.updateCurrentTime = function(self)
	local timeEngine = self.graphicEngine.rhythmModel.timeEngine
	local timePoint = self.currentTimePoint
	timePoint.absoluteTime = timeEngine.currentVisualTime - timeEngine.inputOffset

	local spaceData = self.layerData.spaceData

	local nextVelocityData = spaceData:getVelocityData(self.currentVelocityDataIndex + 1)
	while nextVelocityData and nextVelocityData.timePoint <= timePoint do
		self.currentVelocityDataIndex = self.currentVelocityDataIndex + 1
		nextVelocityData = spaceData:getVelocityData(self.currentVelocityDataIndex + 1)
	end

	local prevVelocityData = spaceData:getVelocityData(self.currentVelocityDataIndex - 1)
	while prevVelocityData and prevVelocityData.timePoint > timePoint do
		self.currentVelocityDataIndex = self.currentVelocityDataIndex - 1
		prevVelocityData = spaceData:getVelocityData(self.currentVelocityDataIndex - 1)
	end

	timePoint.velocityData = spaceData:getVelocityData(self.currentVelocityDataIndex)
	timePoint:computeZeroClearVisualTime()
end

NoteDrawer.update = function(self)
	self:updateCurrentTime()

	local notes = self.notes
	local note

	for i = self.startNoteIndex, self.endNoteIndex do
		notes[i]:update()
	end

	for i = self.startNoteIndex, 2, -1 do
		note = notes[i - 1]
		note:update()
		if not note:willDrawBeforeStart() and i == self.startNoteIndex then
			self.startNoteIndex = self.startNoteIndex - 1
		else
			break
		end
	end

	for i = self.endNoteIndex, #notes - 1, 1 do
		note = notes[i + 1]
		note:update()
		if not note:willDrawAfterEnd() and i == self.endNoteIndex then
			self.endNoteIndex = self.endNoteIndex + 1
		else
			break
		end
	end

	for i = self.startNoteIndex, self.endNoteIndex do
		note = notes[i]
		if note:willDrawBeforeStart() then
			self.startNoteIndex = self.startNoteIndex + 1
		else
			break
		end
	end

	for i = self.endNoteIndex, self.startNoteIndex, -1 do
		note = notes[i]
		if note:willDrawAfterEnd() then
			self.endNoteIndex = self.endNoteIndex - 1
		else
			break
		end
	end
end

return NoteDrawer
