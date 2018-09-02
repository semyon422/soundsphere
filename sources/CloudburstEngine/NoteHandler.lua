CloudburstEngine.NoteHandler = createClass(soul.SoulObject)
local NoteHandler = CloudburstEngine.NoteHandler

NoteHandler.loadNoteData = function(self)
	self.noteData = {}
	
	local currentLogicalNote
	for layerDataIndex in self.engine.noteChart:getLayerDataIndexIterator() do
		local layerData = self.engine.noteChart:requireLayerData(layerDataIndex)
		for noteDataIndex = 1, layerData:getNoteDataCount() do
			local noteData = layerData:getNoteData(noteDataIndex)
			
			if noteData.inputType == self.inputType and noteData.inputIndex == self.inputIndex then
				local logicalNote
				
				local soundFilePath
				if noteData.soundFileName then
					if not self.engine.soundFiles[noteData.soundFileName] then
						self.engine.soundFiles[noteData.soundFileName] = self.engine.fileManager:findFile(noteData.soundFileName, "audio")
					end
					soundFilePath = self.engine.soundFiles[noteData.soundFileName]
				end
				
				if noteData.noteType == "ShortNote" then
					logicalNote = self.engine.ShortLogicalNote:new({
						startNoteData = noteData,
						pressSoundFilePath = soundFilePath
					})
					table.insert(self.noteData, logicalNote)
				elseif noteData.noteType == "LongNoteStart" then
					logicalNote = self.engine.LongLogicalNote:new({
						startNoteData = noteData,
						pressSoundFilePath = soundFilePath
					})
					currentLogicalNote = logicalNote
					table.insert(self.noteData, logicalNote)
				elseif noteData.noteType == "LongNoteEnd" then
					if currentLogicalNote then
						logicalNote = currentLogicalNote
						logicalNote.endNoteData = noteData
						logicalNote.releaseSoundFilePath = soundFilePath
					end
					currentLogicalNote = 0
				elseif noteData.noteType == "SoundNote" then
					logicalNote = self.engine.SoundNote:new({
						startNoteData = noteData,
						pressSoundFilePath = soundFilePath
					})
					table.insert(self.noteData, logicalNote)
				end
				
				if logicalNote then
					logicalNote.noteHandler = self
					logicalNote.engine = self.engine
					
					self.engine.sharedLogicalNoteData[noteData] = logicalNote
				end
			end
		end
	end
	
	table.sort(self.noteData, function(a, b)
		return a.startNoteData.timePoint < b.startNoteData.timePoint
	end)

	for index, logicalNote in ipairs(self.noteData) do
		logicalNote.index = index
	end
	
	self.startNoteIndex = 1
	self.currentNote = self.noteData[1]
end

NoteHandler.setKeyState = function(self)
	self.keyBind = tostring(self.engine.inputMode:getInput(self.inputType, self.inputIndex))
	self.keyState = love.keyboard.isDown(self.keyBind)
end

NoteHandler.receiveEvent = function(self, event)
	if event.name == "love.update" then
		self.currentNote:update()
	end
	
	local key = event.data and event.data[1]
	if self.keyBind and key == self.keyBind then
		if event.name == "love.keypressed" then
			self.keyState = true
			self.currentNote.keyState = true
			self:sendState()
			
			if self.currentNote.pressSoundFilePath then
				self.engine.core.audioManager:playSound(self.currentNote.pressSoundFilePath)
			end
		elseif event.name == "love.keyreleased" then
			self.keyState = false
			self.currentNote.keyState = false
			self:sendState()
			
			if self.currentNote.releaseSoundFilePath then
				self.engine.core.audioManager:playSound(self.currentNote.releaseSoundFilePath)
			end
		end
	end
end

NoteHandler.sendState = function(self)
	self.engine.observable:sendEvent({
		name = "noteHandlerUpdated",
		noteHandler = self
	})
end

NoteHandler.load = function(self)
	self:loadNoteData()
	if self.inputType ~= "auto" then
		self:setKeyState()
	end
end

NoteHandler.unload = function(self)
end