local ShortGraphicalNote = require("sphere.models.RhythmModel.GraphicEngine.ShortGraphicalNote")

local ShortEditorNote = ShortGraphicalNote + {}

function ShortEditorNote:create(absoluteTime)
	local editorModel = self.editorModel
	local ld = editorModel.layerData

	local dtp = editorModel:getDtpAbsolute(absoluteTime)
	local noteData = ld:getNoteData(dtp, self.inputType, self.inputIndex)
	if not noteData then
		return
	end
	noteData.noteType = "ShortNote"
	self.startNoteData = noteData

	return self
end

function ShortEditorNote:grab(t, part, deltaColumn, lockSnap)
	local note = self

	note.grabbedPart = part
	note.grabbedDeltaColumn = deltaColumn

	note.startNoteData = note.startNoteData:clone()

	if lockSnap then
		return
	end

	note.grabbedDeltaTime = t - note.startNoteData.timePoint.absoluteTime
	note.startNoteData.timePoint = note.startNoteData.timePoint:clone()
end

function ShortEditorNote:drop(t)
	local editorModel = self.editorModel
	local ld = editorModel.layerData
	local dtp = editorModel:getDtpAbsolute(t - self.grabbedDeltaTime)
	self.startNoteData.timePoint = ld:checkTimePoint(dtp)
end

function ShortEditorNote:updateGrabbed(t)
	local editorModel = self.editorModel
	editorModel:getDtpAbsolute(t - self.grabbedDeltaTime):clone(self.startNoteData.timePoint)
end

function ShortEditorNote:copy(copyTimePoint)
	self.deltaStartTime = self.startNoteData.timePoint:sub(copyTimePoint)
end

function ShortEditorNote:paste(timePoint)
	local ld = self.editorModel.layerData

	self.startNoteData = self.startNoteData:clone()
	self.startNoteData.timePoint = ld:getTimePoint(timePoint:add(self.deltaStartTime))
end

function ShortEditorNote:remove()
	local ld = self.editorModel.layerData

	ld:removeNoteData(self.startNoteData, self.inputType, self.inputIndex)
end

function ShortEditorNote:add()
	local ld = self.editorModel.layerData

	ld:addNoteData(self.startNoteData, self.inputType, self.inputIndex)
end

return ShortEditorNote
