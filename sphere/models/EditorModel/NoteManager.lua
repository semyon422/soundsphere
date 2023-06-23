local Class = require("Class")
local EditorNoteFactory = require("sphere.models.EditorModel.EditorNoteFactory")

local NoteManager = Class:new()

NoteManager.construct = function(self)
	self.grabbedNotes = {}
end

NoteManager.getColumnOver = function(self)
	local mx, my = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	local noteSkin = self.editorModel.noteSkin
	return noteSkin:getInverseColumnPosition(mx)
end

NoteManager.update = function(self)
	local editor = self.editorModel:getSettings()
	local noteSkin = self.editorModel.noteSkin

	for _, note in ipairs(self.grabbedNotes) do
		local time = self.editorModel:getMouseTime()
		if not editor.lockSnap then
			note:updateGrabbed(time)
		end
		local column = self:getColumnOver()
		if column then
			column = column - note.grabbedDeltaColumn
			local inputType, inputIndex = noteSkin:getColumnInput(column, true)
			note.inputType = inputType
			note.inputIndex = inputIndex
		end
	end
end

NoteManager.copyNotes = function(self, cut)
	if cut then
		self.editorModel.editorChanges:reset()
	end
	-- local noteSkin = self.editorModel.noteSkin

	self.copiedNotes = {}
	local copyTimePoint

	for _, note in ipairs(self.editorModel.graphicEngine.selectedNotes) do
		-- local _column = noteSkin:getInputColumn(note.inputType, note.inputIndex)
		-- if _column then
			if not copyTimePoint or note.startNoteData.timePoint < copyTimePoint then
				copyTimePoint = note.startNoteData.timePoint
			end
			table.insert(self.copiedNotes, note)
			if cut then
				self:_removeNote(note)
			end
		-- end
	end

	for _, note in ipairs(self.copiedNotes) do
		note:copy(copyTimePoint)
	end
	if cut then
		self.editorModel.editorChanges:next()
	end
end

NoteManager.deleteNotes = function(self)
	self.editorModel.editorChanges:reset()
	local c = 0
	-- local noteSkin = self.editorModel.noteSkin
	for _, note in ipairs(self.editorModel.graphicEngine.selectedNotes) do
		-- local _column = noteSkin:getInputColumn(note.inputType, note.inputIndex)
		-- if _column then
			self:_removeNote(note)
			c = c + 1
		-- end
	end
	self.editorModel.editorChanges:next()
	return c
end

NoteManager.pasteNotes = function(self)
	local copiedNotes = self.copiedNotes
	if not copiedNotes then
		return
	end

	self.editorModel.editorChanges:reset()
	local timePoint = self.editorModel.timePoint
	for _, note in ipairs(copiedNotes) do
		note:paste(timePoint)
		self:_addNote(note)
	end
	self.editorModel.editorChanges:next()
end

NoteManager.grabNotes = function(self, part, mouseTime)
	local noteSkin = self.editorModel.noteSkin
	local editor = self.editorModel:getSettings()

	self.grabbedNotes = {}
	self.editorModel.editorChanges:reset()
	local column = self:getColumnOver()
	for _, note in ipairs(self.editorModel.graphicEngine.selectedNotes) do
		local _column = noteSkin:getInputColumn(note.inputType, note.inputIndex)
		if _column then
			table.insert(self.grabbedNotes, note)
			self:_removeNote(note)
			note:grab(mouseTime, part, column - _column, editor.lockSnap)
		end
	end
end

NoteManager.dropNotes = function(self, mouseTime)
	local editor = self.editorModel:getSettings()
	local grabbedNotes = self.grabbedNotes
	self.grabbedNotes = {}

	if editor.lockSnap then
		for _, note in ipairs(grabbedNotes) do
			self:_addNote(note)
		end
		self.editorModel.editorChanges:next()
		return
	end

	local t = mouseTime
	for _, note in ipairs(grabbedNotes) do
		note:drop(t)
		self:_addNote(note)
	end
	self.editorModel.editorChanges:next()
end

NoteManager._removeNote = function(self, note)
	note:remove()
	self.editorModel.editorChanges:add()
end

NoteManager.removeNote = function(self, note)
	self.editorModel.editorChanges:reset()
	self:_removeNote(note)
	self.editorModel.editorChanges:next()
end

NoteManager._addNote = function(self, note)
	note:add()
	self.editorModel.editorChanges:add()
end

NoteManager.newNote = function(self, noteType, absoluteTime, inputType, inputIndex)
	local note = EditorNoteFactory:newNote(noteType)
	if not note then
		return
	end
	note.editorModel = self.editorModel
	note.currentTimePoint = self.editorModel.timePoint
	note.graphicEngine = self.editorModel.graphicEngine
	note.layerData = self.editorModel.layerData
	note.inputType = inputType
	note.inputIndex = inputIndex
	return note:create(absoluteTime)
end

NoteManager.addNote = function(self, absoluteTime, inputType, inputIndex)
	self.editorModel.editorChanges:reset()
	local editor = self.editorModel:getSettings()
	self.editorModel.graphicEngine:selectNote()

	local note
	if editor.tool == "ShortNote" then
		note = self:newNote("ShortNote", absoluteTime, inputType, inputIndex)
	elseif editor.tool == "LongNote" then
		note = self:newNote("LongNoteStart", absoluteTime, inputType, inputIndex)
	end

	if note and editor.tool == "LongNote" then
		self.editorModel.graphicEngine:selectNote(note)
		self:grabNotes("tail", note.endNoteData.timePoint.absoluteTime)
	end
	self.editorModel.editorChanges:add()
	self.editorModel.editorChanges:next()
end

return NoteManager
