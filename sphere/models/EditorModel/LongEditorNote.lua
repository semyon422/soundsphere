local EditorNote = require("sphere.models.EditorModel.EditorNote")
local LongGraphicalNote = require("sphere.models.RhythmModel.GraphicEngine.LongGraphicalNote")
local VisualPoint = require("chartedit.VisualPoint")
local Note = require("ncdk2.notes.Note")

---@class sphere.LongEditorNote: sphere.EditorNote, sphere.LongGraphicalNote
---@operator call: sphere.LongEditorNote
local LongEditorNote = EditorNote + LongGraphicalNote

---@param absoluteTime number
---@return sphere.LongEditorNote?
function LongEditorNote:create(absoluteTime)
	local editorModel = self.editorModel
	local layer = editorModel.layer

	local dtp = editorModel:getDtpAbsolute(absoluteTime)
	local p = layer.points:saveSearchPoint(dtp)
	local vp = layer.visual:getPoint(p)
	local startNote = Note()
	startNote.visualPoint = vp
	startNote.noteType = "LongNoteStart"
	self.startNote = startNote

	local p = layer.points:getPoint(editorModel.scroller:getNextSnapIntervalTime(p, 1))
	local vp = layer.visual:getPoint(p)
	local endNote = Note()
	endNote.visualPoint = vp
	endNote.noteType = "LongNoteEnd"
	self.endNote = endNote

	endNote.startNote = startNote
	startNote.endNote = endNote

	self:update()

	return self
end

---@param t number
---@param part string
---@param deltaColumn number
---@param lockSnap boolean
function LongEditorNote:grab(t, part, deltaColumn, lockSnap)
	self.grabbedPart = part
	self.grabbedDeltaColumn = deltaColumn

	if lockSnap then
		return
	end

	self.startNote = self.startNote:clone()
	self.endNote = self.endNote:clone()

	self.startNote.endNote = self.endNote
	self.endNote.startNote = self.startNote

	local startTime = self.startNote.visualPoint.point.absoluteTime
	local endTime = self.endNote.visualPoint.point.absoluteTime
	if part == "head" then
		self.grabbedDeltaTime = t - startTime
		self.startNote.visualPoint = VisualPoint({})
	elseif part == "tail" then
		self.grabbedDeltaTime = t - endTime
		self.endNote.visualPoint = VisualPoint({})
	elseif part == "body" then
		self.grabbedDeltaTime = {
			t - startTime,
			t - endTime,
		}
		self.startNote.visualPoint = VisualPoint({})
		self.endNote.visualPoint = VisualPoint({})
	end
	self:updateGrabbed(t)
end

---@param t number
function LongEditorNote:drop(t)
	local editorModel = self.editorModel
	local layer = editorModel.layer
	if self.grabbedPart == "head" then
		local dtp = editorModel:getDtpAbsolute(t - self.grabbedDeltaTime)
		local p = layer.points:saveSearchPoint()
		if p == self.endNote.visualPoint.point then
			p = layer.points:getPoint(editorModel.scroller:getNextSnapIntervalTime(p, -1))
		end
		local vp = layer.visual:getPoint(p)
		self.startNote.visualPoint = vp
	elseif self.grabbedPart == "tail" then
		local dtp = editorModel:getDtpAbsolute(t - self.grabbedDeltaTime)
		local p = layer.points:saveSearchPoint()
		if self.startNote.timePoint == p then
			p = layer.points:getPoint(editorModel.scroller:getNextSnapIntervalTime(p, 1))
		end
		local vp = layer.visual:getPoint(p)
		self.endNote.visualPoint = vp
	elseif self.grabbedPart == "body" then
		local dtp = editorModel:getDtpAbsolute(t - self.grabbedDeltaTime[1])
		local p = layer.points:saveSearchPoint()
		local vp = layer.visual:getPoint(p)
		self.startNote.visualPoint = vp
		local dtp = editorModel:getDtpAbsolute(t - self.grabbedDeltaTime[2])
		local p = layer.points:saveSearchPoint()
		local vp = layer.visual:getPoint(p)
		self.endNote.visualPoint = vp
	end
end

---@param t number
function LongEditorNote:updateGrabbed(t)
	local editorModel = self.editorModel
	if self.grabbedPart == "head" then
		editorModel:getDtpAbsolute(t - self.grabbedDeltaTime):clone(self.startNote.visualPoint.point)
	elseif self.grabbedPart == "tail" then
		editorModel:getDtpAbsolute(t - self.grabbedDeltaTime):clone(self.endNote.visualPoint.point)
	elseif self.grabbedPart == "body" then
		editorModel:getDtpAbsolute(t - self.grabbedDeltaTime[1]):clone(self.startNote.visualPoint.point)
		editorModel:getDtpAbsolute(t - self.grabbedDeltaTime[2]):clone(self.endNote.visualPoint.point)
	end
end

---@param copyTimePoint ncdk.IntervalTimePoint
function LongEditorNote:copy(copyTimePoint)
	self.deltaStartTime = self.startNote.timePoint:sub(copyTimePoint)
	self.deltaEndTime = self.endNote.timePoint:sub(copyTimePoint)
end

---@param timePoint ncdk.IntervalTimePoint
function LongEditorNote:paste(timePoint)
	local ld = self.editorModel.layerData

	self.startNote = self.startNote:clone()
	self.endNote = self.endNote:clone()

	self.startNote.timePoint = ld:getTimePoint(timePoint:add(self.deltaStartTime))
	self.endNote.timePoint = ld:getTimePoint(timePoint:add(self.deltaEndTime))

	self.endNote.startNote = self.startNote
	self.startNote.endNote = self.endNote
end

function LongEditorNote:remove()
	local layer = self.editorModel.layer
	layer:removeNote(self.startNote, self.column)
	layer:removeNote(self.endNote, self.column)
end

function LongEditorNote:add()
	local layer = self.editorModel.layer
	layer:addNote(self.startNote, self.column)
	layer:addNote(self.endNote, self.column)
end

return LongEditorNote
