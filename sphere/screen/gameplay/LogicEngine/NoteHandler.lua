local Class				= require("aqua.util.Class")
local ShortLogicalNote	= require("sphere.screen.gameplay.LogicEngine.ShortLogicalNote")
local LongLogicalNote	= require("sphere.screen.gameplay.LogicEngine.LongLogicalNote")

local NoteHandler = Class:new()

NoteHandler.autoplayDelay = 1/15

NoteHandler.loadNoteData = function(self)
	self.noteData = {}
	
	local logicEngine = self.logicEngine
	for layerDataIndex in logicEngine.noteChart:getLayerDataIndexIterator() do
		local layerData = logicEngine.noteChart:requireLayerData(layerDataIndex)
		for noteDataIndex = 1, layerData:getNoteDataCount() do
			local noteData = layerData:getNoteData(noteDataIndex)
			
			if noteData.inputType == self.inputType and noteData.inputIndex == self.inputIndex then
				local logicalNote
				
				if noteData.noteType == "ShortNote" then
					logicalNote = ShortLogicalNote:new({
						startNoteData = noteData,
						pressSounds = noteData.sounds,
						noteType = "ShortNote"
					})
					logicEngine.noteCount = logicEngine.noteCount + 1
				elseif noteData.noteType == "LongNoteStart" then
					logicalNote = LongLogicalNote:new({
						startNoteData = noteData,
						endNoteData = noteData.endNoteData,
						pressSounds = noteData.sounds,
						releaseSounds = noteData.endNoteData.sounds,
						noteType = "LongNote"
					})
					logicEngine.noteCount = logicEngine.noteCount + 1
				elseif noteData.noteType == "LineNoteStart" then
					logicalNote = ShortLogicalNote:new({
						startNoteData = noteData,
						endNoteData = noteData.endNoteData,
						pressSounds = noteData.sounds,
						noteType = "SoundNote"
					})
				elseif noteData.noteType == "SoundNote" then
					logicalNote = ShortLogicalNote:new({
						startNoteData = noteData,
						pressSounds = noteData.sounds,
						noteType = "SoundNote"
					})
				end
				
				if logicalNote then
					logicalNote.noteHandler = self
					logicalNote.logicEngine = logicEngine
					logicalNote.score = logicEngine.score
					table.insert(self.noteData, logicalNote)
					
					logicEngine.sharedLogicalNoteData[noteData] = logicalNote
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
	self.keyBind = self.inputType .. self.inputIndex
	self.keyState = love.keyboard.isDown(self.keyBind)
end

NoteHandler.update = function(self)
	if not self.currentNote then return end
	
	self.currentNote:update()
	if self.click then
		self.keyTimer = self.keyTimer + love.timer.getDelta()
		if self.keyTimer > self.autoplayDelay then
			self.click = false
			self:switchKey(false)
		end
	end
end

NoteHandler.receive = function(self, event)
	if not self.currentNote then return end
	
	local key = event.args and event.args[1]
	if self.keyBind and key == self.keyBind then
		local currentNote = self.currentNote
		if event.name == "keypressed" then
			self.logicEngine:playAudio(currentNote.pressSounds, "fga", currentNote.startNoteData.keysound)
			
			self.currentNote.keyState = true
			return self:switchKey(true)
		elseif event.name == "keyreleased" then
			self.logicEngine:playAudio(currentNote.releaseSounds, "fga", currentNote.startNoteData.keysound)
			
			self.currentNote.keyState = false
			return self:switchKey(false)
		end
	end
end

NoteHandler.switchKey = function(self, state)
	self.keyState = state
	return self:sendState()
end

NoteHandler.clickKey = function(self)
	self.keyTimer = 0
	self.click = true
	self.keyState = true
	
	return self:sendState()
end

NoteHandler.sendState = function(self)
	return self.logicEngine.observable:send({
		name = "noteHandlerUpdated",
		noteHandler = self
	})
end

NoteHandler.load = function(self)
	self:loadNoteData()
	self:setKeyState()
end

NoteHandler.unload = function(self) end

return NoteHandler
