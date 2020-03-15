local Class				= require("aqua.util.Class")
local ShortLogicalNote	= require("sphere.screen.gameplay.LogicEngine.ShortLogicalNote")
local LongLogicalNote	= require("sphere.screen.gameplay.LogicEngine.LongLogicalNote")

local NoteHandler = Class:new()

-- NoteHandler.autoplayDelay = 1/15

NoteHandler.load = function(self)
	self:loadNoteData()
	
	self.keyBind = self.inputType .. self.inputIndex
	self.keyState = false
end

NoteHandler.unload = function(self) end

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
						noteData = noteData,
						noteType = "ShortNote"
					})
					logicEngine.noteCount = logicEngine.noteCount + 1
				elseif noteData.noteType == "LongNoteStart" then
					logicalNote = LongLogicalNote:new({
						noteData = noteData,
						noteType = "LongNote"
					})
					logicEngine.noteCount = logicEngine.noteCount + 1
				else
					logicalNote = ShortLogicalNote:new({
						noteData = noteData,
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

NoteHandler.update = function(self)
	if not self.currentNote then return end
	
	self.currentNote:update()
	-- if self.click then
	-- 	self.keyTimer = self.keyTimer + love.timer.getDelta()
	-- 	if self.keyTimer > self.autoplayDelay then
	-- 		self.click = false
	-- 		self:switchKey(false)
	-- 	end
	-- end
end

NoteHandler.receive = function(self, event)
	if not self.currentNote then return end
	
	local key = event.args and event.args[1]
	if key == self.keyBind then
		local currentNote = self.currentNote
		if event.name == "keypressed" then
			currentNote.keyState = true
			self.keyState = true
			return self:send({
				name = "KeyState",
				state = true,
				note = currentNote,
				layer = "foreground"
			})
		elseif event.name == "keyreleased" then
			currentNote.keyState = false
			self.keyState = false
			return self:send({
				name = "KeyState",
				state = false,
				note = currentNote,
				layer = "foreground"
			})
		end
	end
end

-- NoteHandler.clickKey = function(self)
-- 	self.keyTimer = 0
-- 	self.click = true
-- 	self.keyState = true
	
-- 	return self:sendState()
-- end

NoteHandler.send = function(self, event)
	return self.logicEngine.observable:send(event)
end

return NoteHandler
