local class = require("class")
local EditorNoteFactory = require("sphere.models.EditorModel.EditorNoteFactory")

local NoteManager = class()

function NoteManager:new()
	self.grabbedNotes = {}
end

function NoteManager:getColumnOver()
	local mx, my = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	local noteSkin = self.editorModel.noteSkin
	return noteSkin:getInverseColumnPosition(mx)
end

function NoteManager:update()
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

function NoteManager:copyNotes(cut)
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

function NoteManager:deleteNotes()
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

function NoteManager:pasteNotes()
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

function NoteManager:grabNotes(part, mouseTime)
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

function NoteManager:dropNotes(mouseTime)
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

function NoteManager:_removeNote(note)
	note:remove()
	self.editorModel.editorChanges:add()
end

function NoteManager:removeNote(note)
	self.editorModel.editorChanges:reset()
	self:_removeNote(note)
	self.editorModel.editorChanges:next()
end

function NoteManager:_addNote(note)
	note:add()
	self.editorModel.editorChanges:add()
end

function NoteManager:newNote(noteType, absoluteTime, inputType, inputIndex)
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

function NoteManager:addNote(absoluteTime, inputType, inputIndex)
	local editorModel = self.editorModel
	editorModel.editorChanges:reset()
	local editor = editorModel:getSettings()
	editorModel.graphicEngine:selectNote()

	local note
	if editor.tool == "ShortNote" then
		note = self:newNote("ShortNote", absoluteTime, inputType, inputIndex)
	elseif editor.tool == "LongNote" then
		note = self:newNote("LongNoteStart", absoluteTime, inputType, inputIndex)
	end

	if not note then
		return
	end

	editorModel.graphicEngine:selectNote(note)
	if editor.tool == "ShortNote" then
		self:grabNotes("head", editorModel:getMouseTime())
	elseif editor.tool == "LongNote" then
		self:grabNotes(
			"tail",
			editorModel:getMouseTime() + note.endNoteData.timePoint.absoluteTime - note.startNoteData.timePoint.absoluteTime
		)
	end
end

function NoteManager:flipNotes()
	local editorModel = self.editorModel
	local noteSkin = self.editorModel.noteSkin

	editorModel.editorChanges:reset()

	local notes = {}

	for _, note in ipairs(editorModel.graphicEngine.selectedNotes) do
		table.insert(notes, note)
		self:_removeNote(note)
	end

	for _, note in ipairs(notes) do
		local columns = noteSkin.inputsCount
		local column = columns - noteSkin:getInputColumn(note.inputType, note.inputIndex) + 1
		local inputType, inputIndex = noteSkin:getColumnInput(column, true)
		note.inputType = inputType
		note.inputIndex = inputIndex
		self:_addNote(note)
	end

	editorModel.editorChanges:next()
end

return NoteManager
