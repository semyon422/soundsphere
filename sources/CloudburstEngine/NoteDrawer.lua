CloudburstEngine.NoteDrawer = createClass()
local NoteDrawer = CloudburstEngine.NoteDrawer

NoteDrawer.loadNoteData = function(self)
	self.noteData = {}
	
	self.layerData = self.engine.noteChart:requireLayerData(self.layerIndex)
	local inputModeString = self.layerData.layerDataSequence.noteChart.inputMode:getString()
	
	for noteDataIndex = 1, self.layerData:getNoteDataCount() do
		local noteData = self.layerData:getNoteData(noteDataIndex)
		
		if noteData.inputType == self.inputType and noteData.inputIndex == self.inputIndex then
			local graphicalNote
			if noteData.noteType == "ShortNote" then
				graphicalNote = self.engine.ShortGraphicalNote:new({
					startNoteData = noteData,
					inputModeString = inputModeString,
					noteType = "ShortNote"
				})
				
				if self.engine.noteSkin:checkNote(graphicalNote) then
					table.insert(self.noteData, graphicalNote)
				end
			elseif noteData.noteType == "LongNoteStart" then
				graphicalNote = self.engine.LongGraphicalNote:new({
					startNoteData = noteData,
					endNoteData = noteData.endNoteData,
					inputModeString = inputModeString,
					noteType = "LongNote"
				})
				
				if self.engine.noteSkin:checkNote(graphicalNote, "Head") and
					self.engine.noteSkin:checkNote(graphicalNote, "Tail") and
					self.engine.noteSkin:checkNote(graphicalNote, "Body")
				then
					table.insert(self.noteData, graphicalNote)
				end
			elseif noteData.noteType == "LineNoteStart" then
				graphicalNote = self.engine.LineGraphicalNote:new({
					startNoteData = noteData,
					endNoteData = noteData.endNoteData,
					inputModeString = inputModeString,
					noteType = "LineNote"
				})
				
				table.insert(self.noteData, graphicalNote)
			elseif noteData.noteType == "SoundNote" then
				graphicalNote = self.engine.ShortGraphicalNote:new({
					startNoteData = noteData,
					noteType = "SoundNote"
				})
				
				if self.engine.noteSkin:checkNote(graphicalNote) then
					table.insert(self.noteData, graphicalNote)
				end
			end
			if graphicalNote then
				graphicalNote.noteDrawer = self
				graphicalNote.engine = self.engine
				graphicalNote.inputPointer = graphicalNote.startNoteData.inputType .. graphicalNote.startNoteData.inputIndex
				graphicalNote:updateLogicalNote()
			end
		end
	end
	
	self.currentTimePoint = self.layerData:getTimePoint()
	self.currentClearVisualTime = 0
	self.currentVelocityDataIndex = 1
	
	table.sort(self.noteData, function(a, b)
		return a.startNoteData.zeroClearVisualTime < b.startNoteData.zeroClearVisualTime
	end)
	
	for index, graphicalNote in ipairs(self.noteData) do
		graphicalNote.index = index
	end
	
	self.startNoteIndex = 1
	self.endNoteIndex = 0
	self.drawingNotes = {}
end

NoteDrawer.updateCurrentTime = function(self)
	self.currentTimePoint.absoluteTime = self.engine.currentTime
	
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
	self.currentClearVisualTime
		= (self.currentTimePoint:getAbsoluteTime() - self.currentVelocityData.timePoint:getAbsoluteTime())
		* self.currentVelocityData.currentSpeed:tonumber()
		+ self.currentVelocityData.timePoint.zeroClearVisualTime
	self.currentTimePoint.velocityData = self.currentVelocityData
end

NoteDrawer.update = function(self)
	self:updateCurrentTime()
	
	self.globalSpeed = self.currentTimePoint.velocityData.globalSpeed:tonumber()
	for currentNoteIndex = self.startNoteIndex, 0, -1 do
		local note = self.noteData[currentNoteIndex - 1]
		if note then
			note:computeVisualTime()
			if not note:willDrawBeforeStart() and note.index == self.startNoteIndex - 1 then
				self.drawingNotes[note] = note
				self.startNoteIndex = self.startNoteIndex - 1
				note:activate()
			else
				break
			end
		else
			break
		end
	end
	for currentNoteIndex = self.endNoteIndex, #self.noteData, 1 do
		local note = self.noteData[currentNoteIndex + 1]
		if note then
			note:computeVisualTime()
			if not note:willDrawAfterEnd() and note.index == self.endNoteIndex + 1 then
				self.drawingNotes[note] = note
				self.endNoteIndex = self.endNoteIndex + 1
				note:activate()
			else
				break
			end
		else
			break
		end
	end
	
	for _, note in pairs(self.drawingNotes) do
		if note.activated then
			note:update()
		else
			self.drawingNotes[note] = nil
		end
	end
end

NoteDrawer.load = function(self)
	self:loadNoteData()
end

NoteDrawer.unload = function(self)
	for _, note in ipairs(self.noteData) do
		if note.activated then
			note:deactivate()
		end
	end
end

NoteDrawer.getVelocityDataByTime = function(self, time)
	for index = 1, #self.velocityData do
		local currentVelocity = self.velocityData[index]
		local nextVelocity = self.velocityData[index + 1]
		
		if time >= currentVelocity.startTime and time < nextVelocity.startTime then
			return currentVelocity
		end
	end
end

NoteDrawer.getVelocityByIndex = function(self, index)
	return self.velocityData[index]
end
