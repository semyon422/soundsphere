local EditorNote = require("sphere.models.EditorModel.EditorNote")
local ShortGraphicalNote = require("sphere.models.RhythmModel.GraphicEngine.ShortGraphicalNote")

---@class sphere.ShortEditorNote: sphere.EditorNote, sphere.ShortGraphicalNote
---@operator call: sphere.ShortEditorNote
local ShortEditorNote = EditorNote + ShortGraphicalNote

---@param absoluteTime number
---@return sphere.ShortEditorNote?
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

---@param t number
---@param part string
---@param deltaColumn number
---@param lockSnap boolean
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

---@param t number
function ShortEditorNote:drop(t)
	local editorModel = self.editorModel
	local ld = editorModel.layerData
	local dtp = editorModel:getDtpAbsolute(t - self.grabbedDeltaTime)
	self.startNoteData.timePoint = ld:checkTimePoint(dtp)
end

---@param t number
function ShortEditorNote:updateGrabbed(t)
	local editorModel = self.editorModel
	editorModel:getDtpAbsolute(t - self.grabbedDeltaTime):clone(self.startNoteData.timePoint)
end

---@param copyTimePoint ncdk.IntervalTimePoint
function ShortEditorNote:copy(copyTimePoint)
	self.deltaStartTime = self.startNoteData.timePoint:sub(copyTimePoint)
end

---@param timePoint ncdk.IntervalTimePoint
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
