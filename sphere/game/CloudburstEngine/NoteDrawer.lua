local Class = require("aqua.util.Class")
local ShortGraphicalNote = require("sphere.game.CloudburstEngine.note.ShortGraphicalNote")
local LongGraphicalNote = require("sphere.game.CloudburstEngine.note.LongGraphicalNote")
local LineGraphicalNote = require("sphere.game.CloudburstEngine.note.LineGraphicalNote")

local NoteDrawer = Class:new()

NoteDrawer.load = function(self)
	self.noteData = {}
	
	self.layerData = self.engine.noteChart:requireLayerData(self.layerIndex)
	local inputModeString = self.layerData.layerDataSequence.noteChart.inputMode:getString()
	
	for noteDataIndex = 1, self.layerData:getNoteDataCount() do
		local noteData = self.layerData:getNoteData(noteDataIndex)
		
		if noteData.inputType == self.inputType and noteData.inputIndex == self.inputIndex then
			local graphicalNote
			if noteData.noteType == "ShortNote" then
				graphicalNote = ShortGraphicalNote:new({
					startNoteData = noteData,
					inputModeString = inputModeString,
					noteType = "ShortNote"
				})
			elseif noteData.noteType == "LongNoteStart" then
				graphicalNote = LongGraphicalNote:new({
					startNoteData = noteData,
					endNoteData = noteData.endNoteData,
					inputModeString = inputModeString,
					noteType = "LongNote"
				})
			elseif noteData.noteType == "LineNoteStart" then
				graphicalNote = LineGraphicalNote:new({
					startNoteData = noteData,
					endNoteData = noteData.endNoteData,
					inputModeString = inputModeString,
					noteType = "LineNote"
				})
			elseif noteData.noteType == "SoundNote" then
				graphicalNote = ShortGraphicalNote:new({
					startNoteData = noteData,
					noteType = "SoundNote"
				})
			end
			if graphicalNote then
				graphicalNote.noteDrawer = self
				graphicalNote.engine = self.engine
				graphicalNote.container = self.engine.container
				graphicalNote.noteSkin = self.engine.noteSkin
				graphicalNote:init()
				if self.engine.noteSkin:checkNote(graphicalNote) then
					table.insert(self.noteData, graphicalNote)
				end
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
	
	local note
	for currentNoteIndex = self.startNoteIndex, 0, -1 do
		note = self.noteData[currentNoteIndex - 1]
		if note then
			note:computeVisualTime()
			if not note:willDrawBeforeStart() and note.index == self.startNoteIndex - 1 then
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
		note = self.noteData[currentNoteIndex + 1]
		if note then
			note:computeVisualTime()
			if not note:willDrawAfterEnd() and note.index == self.endNoteIndex + 1 then
				self.endNoteIndex = self.endNoteIndex + 1
				note:activate()
			else
				break
			end
		else
			break
		end
	end
	
	for currentNoteIndex = self.startNoteIndex, self.endNoteIndex do
		note = self.noteData[currentNoteIndex]
		if note.activated then
			note:update()
		end
	end
end

NoteDrawer.unload = function(self)
	local note
	for currentNoteIndex = self.startNoteIndex, self.endNoteIndex do
		note = self.noteData[currentNoteIndex]
		if note.activated then
			note:deactivate()
		end
	end
end

return NoteDrawer
