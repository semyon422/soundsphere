CloudburstEngine.NoteDrawer = createClass()
local NoteDrawer = CloudburstEngine.NoteDrawer

NoteDrawer.OptimisationModeEnum = {
	UpdateAll = 0,
	UpdateVisible = 1
}

NoteDrawer.optimisationMode = NoteDrawer.OptimisationModeEnum.UpdateVisible

local getClassForNote = function(noteData)
	if noteData.noteType == "ShortNote" then
		return CloudburstEngine.ShortGraphicalNote
	elseif noteData.noteType == "LongNote" then
		return CloudburstEngine.LongGraphicalNote
	elseif noteData.noteType == "SoundNote" then
		return CloudburstEngine.ShortGraphicalNote
	end
end

NoteDrawer.loadNoteData = function(self)
	self.noteData = {}
	
	self.layerData = self.engine.noteChart:requireLayerData(self.layerIndex)
	for noteDataIndex = 1, self.layerData:getNoteDataCount() do
		local noteData = self.layerData:getNoteData(noteDataIndex)
		
		local graphicalNote = getClassForNote(noteData):new({
			noteData = noteData,
			noteDrawer = self,
			engine = self.engine
		})
		
		table.insert(self.noteData, graphicalNote)
	end
	
	self.currentTimePoint = self.layerData:getTimePoint(nil, 1)
	self.currentTimePoint.absoluteTime = self.engine.currentTime
	self.currentTimePoint.velocityData = self.layerData:getVelocityDataByTimePoint(self.currentTimePoint)
	
	table.sort(self.noteData, function(a, b)
		return a.noteData.zeroClearVisualStartTime < b.noteData.zeroClearVisualStartTime
	end)
	
	for index, graphicalNote in ipairs(self.noteData) do
		graphicalNote.index = index
	end
	
	if self.optimisationMode == self.OptimisationModeEnum.UpdateVisible then
		self.startNoteIndex = 1
		self.endNoteIndex = 0
		self.drawingNotes = {}
	end
end

NoteDrawer.update = function(self)
	self.currentTimePoint.absoluteTime = self.engine.currentTime
	self.currentTimePoint.velocityData = self.layerData:getVelocityDataByTimePoint(self.currentTimePoint)
	
	if self.optimisationMode == self.OptimisationModeEnum.UpdateAll then
		self.layerData:computeVisualTime(self.currentTimePoint)
		
		for _, note in ipairs(self.noteData) do
			if note.activated then
				note:update()
			elseif note:willDraw() then
				note:activate()
			end
		end
	elseif self.optimisationMode == self.OptimisationModeEnum.UpdateVisible then
		self.currentClearVisualTime = self.layerData:getVisualTime(self.currentTimePoint, self.layerData:getZeroTimePoint(), true)
		self.globalSpeed = self.currentTimePoint.velocityData.globalSpeed:tonumber()
		
		for currentNoteIndex = self.startNoteIndex, 0, -1 do
			local note = self.noteData[currentNoteIndex - 1]
			if note and note:willDraw() then
				self.drawingNotes[note] = note
				self.startNoteIndex = self.startNoteIndex - 1
				note:activate()
			else
				break
			end
		end
		for currentNoteIndex = self.endNoteIndex, #self.noteData, 1 do
			local note = self.noteData[currentNoteIndex + 1]
			if note and note:willDraw() then
				self.drawingNotes[note] = note
				self.endNoteIndex = self.endNoteIndex + 1
				note:activate()
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
