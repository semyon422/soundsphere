local EditorNote = require("sphere.models.EditorModel.EditorNote")
local ShortGraphicalNote = require("sphere.models.RhythmModel.GraphicEngine.ShortGraphicalNote")
local VisualPoint = require("chartedit.VisualPoint")
local Note = require("ncdk2.notes.Note")

---@class sphere.ShortEditorNote: sphere.EditorNote, sphere.ShortGraphicalNote
---@operator call: sphere.ShortEditorNote
local ShortEditorNote = EditorNote + ShortGraphicalNote

---@param absoluteTime number
---@return sphere.ShortEditorNote?
function ShortEditorNote:create(absoluteTime)
	local editorModel = self.editorModel
	local layer = editorModel.layer

	local dtp = editorModel:getDtpAbsolute(absoluteTime)
	local p = layer.points:saveSearchPoint(dtp)
	local vp = layer.visual:getPoint(p)
	local note = Note()
	note.visualPoint = vp
	self.editorModel.layer:addNote(note, self.column)
	note.noteType = "ShortNote"
	self.startNote = note

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
function ShortEditorNote:paste(point)
	local layer = self.editorModel.layer
	local new_point = layer.points:getPoint(point:add(self.deltaStartTime))
	self.startNote.visualPoint = layer.visual:getPoint(new_point)
	layer:addNote(self.startNote, self.column)
end

function ShortEditorNote:remove()
	print("remove", self.startNote)
	self.editorModel.layer:removeNote(self.startNote, self.column)
end

function ShortEditorNote:add()
	print("add", self.startNote)
	self.editorModel.layer:addNote(self.startNote, self.column)
end

return ShortEditorNote
