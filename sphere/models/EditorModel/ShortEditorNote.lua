local EditorNote = require("sphere.models.EditorModel.EditorNote")
local ShortGraphicalNote = require("sphere.models.RhythmModel.GraphicEngine.ShortGraphicalNote")
local VisualPoint = require("chartedit.VisualPoint")
local Note = require("ncdk2.notes.Note")

---@class sphere.ShortEditorNote: sphere.EditorNote, sphere.ShortGraphicalNote
---@operator call: sphere.ShortEditorNote
local ShortEditorNote = EditorNote + ShortGraphicalNote

---@param absoluteTime number
---@param column ncdk2.Column
---@return sphere.ShortEditorNote?
function ShortEditorNote:create(absoluteTime, column)
	local editorModel = self.editorModel
	local layer = editorModel.layer

	local dtp = editorModel:getDtpAbsolute(absoluteTime)
	local p = layer.points:saveSearchPoint(dtp)
	local vp = layer.visual:getPoint(p)
	local note = Note(vp, column)
	note.noteType = "ShortNote"
	self.startNote = note
	self:update()

	return self
end

---@param t number
---@param part string
---@param deltaColumn number
---@param lockSnap boolean
function ShortEditorNote:grab(t, part, deltaColumn, lockSnap)
	self.grabbedPart = part
	self.grabbedDeltaColumn = deltaColumn

	if lockSnap then
		return
	end

	self.startNote = self.startNote:clone()

	self.grabbedDeltaTime = t - self.startNote.visualPoint.point.absoluteTime
	self.startNote.visualPoint = VisualPoint({})
	self:updateGrabbed(t)
end

---@param t number
function ShortEditorNote:drop(t)
	local editorModel = self.editorModel
	local layer = editorModel.layer
	local dtp = editorModel:getDtpAbsolute(t - self.grabbedDeltaTime)
	local p = layer.points:saveSearchPoint()
	local vp = layer.visual:getPoint(p)
	self.startNote.visualPoint = vp
end

---@param t number
function ShortEditorNote:updateGrabbed(t)
	self.editorModel:getDtpAbsolute(t - self.grabbedDeltaTime):clone(self.startNote.visualPoint.point)
end

---@param copyPoint chartedit.Point
function ShortEditorNote:copy(copyPoint)
	self.deltaStartTime = self.startNote.visualPoint.point:sub(copyPoint)
end

---@param point chartedit.Point
---@return ncdk2.Note[]
function ShortEditorNote:paste(point)
	local layer = self.editorModel.layer
	local new_point = layer.points:getPoint(point:add(self.deltaStartTime))
	local startNote = self.startNote:clone()
	startNote.visualPoint = layer.visual:getPoint(new_point)
	return {startNote}
end

function ShortEditorNote:getNotes()
	return {self.startNote}
end

return ShortEditorNote
