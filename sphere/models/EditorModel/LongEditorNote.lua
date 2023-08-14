local LongGraphicalNote = require("sphere.models.RhythmModel.GraphicEngine.LongGraphicalNote")

local LongEditorNote = LongGraphicalNote + {}

function LongEditorNote:create(absoluteTime)
	local editorModel = self.editorModel
	local ld = editorModel.layerData

	local dtp = editorModel:getDtpAbsolute(absoluteTime)
	local startNoteData = ld:getNoteData(dtp, self.inputType, self.inputIndex)
	if not startNoteData then
		return
	end
	startNoteData.noteType = "LongNoteStart"
	self.startNoteData = startNoteData

	local tp = ld:getTimePoint(editorModel.scroller:getNextSnapIntervalTime(startNoteData.timePoint, 1))
	local endNoteData = ld:getNoteData(tp, self.inputType, self.inputIndex)
	if not endNoteData then
		return
	end
	endNoteData.noteType = "LongNoteEnd"
	self.endNoteData = endNoteData

	endNoteData.startNoteData = startNoteData
	startNoteData.endNoteData = endNoteData

	return self
end

function LongEditorNote:grab(t, part, deltaColumn, lockSnap)
	local note = self

	note.grabbedPart = part
	note.grabbedDeltaColumn = deltaColumn

	note.startNoteData = note.startNoteData:clone()
	note.endNoteData = note.endNoteData:clone()

	note.startNoteData.endNoteData = note.endNoteData
	note.endNoteData.startNoteData = note.startNoteData

	if lockSnap then
		return
	end

	if part == "head" then
		note.grabbedDeltaTime = t - note.startNoteData.timePoint.absoluteTime
		note.startNoteData.timePoint = note.startNoteData.timePoint:clone()
	elseif part == "tail" then
		note.grabbedDeltaTime = t - note.endNoteData.timePoint.absoluteTime
		note.endNoteData.timePoint = note.endNoteData.timePoint:clone()
	elseif part == "body" then
		note.grabbedDeltaTime = {
			t - note.startNoteData.timePoint.absoluteTime,
			t - note.endNoteData.timePoint.absoluteTime,
		}
		note.startNoteData.timePoint = note.startNoteData.timePoint:clone()
		note.endNoteData.timePoint = note.endNoteData.timePoint:clone()
	end
end

function LongEditorNote:drop(t)
	local editorModel = self.editorModel
	local ld = editorModel.layerData
	if self.grabbedPart == "head" then
		local dtp = editorModel:getDtpAbsolute(t - self.grabbedDeltaTime)
		self.startNoteData.timePoint = ld:checkTimePoint(dtp)
		if self.startNoteData.timePoint == self.endNoteData.timePoint then
			local tp = ld:getTimePoint(editorModel.scroller:getNextSnapIntervalTime(self.startNoteData.timePoint, -1))
			self.startNoteData.timePoint = tp
		end
	elseif self.grabbedPart == "tail" then
		local dtp = editorModel:getDtpAbsolute(t - self.grabbedDeltaTime)
		self.endNoteData.timePoint = ld:checkTimePoint(dtp)
		if self.startNoteData.timePoint == self.endNoteData.timePoint then
			local tp = ld:getTimePoint(editorModel.scroller:getNextSnapIntervalTime(self.startNoteData.timePoint, 1))
			self.endNoteData.timePoint = tp
		end
	elseif self.grabbedPart == "body" then
		local dtp = editorModel:getDtpAbsolute(t - self.grabbedDeltaTime[1])
		self.startNoteData.timePoint = ld:checkTimePoint(dtp)
		local dtp = editorModel:getDtpAbsolute(t - self.grabbedDeltaTime[2])
		self.endNoteData.timePoint = ld:checkTimePoint(dtp)
	end
end

function LongEditorNote:updateGrabbed(t)
	local editorModel = self.editorModel
	if self.grabbedPart == "head" then
		editorModel:getDtpAbsolute(t - self.grabbedDeltaTime):clone(self.startNoteData.timePoint)
	elseif self.grabbedPart == "tail" then
		editorModel:getDtpAbsolute(t - self.grabbedDeltaTime):clone(self.endNoteData.timePoint)
	elseif self.grabbedPart == "body" then
		editorModel:getDtpAbsolute(t - self.grabbedDeltaTime[1]):clone(self.startNoteData.timePoint)
		editorModel:getDtpAbsolute(t - self.grabbedDeltaTime[2]):clone(self.endNoteData.timePoint)
	end
end

function LongEditorNote:copy(copyTimePoint)
	self.deltaStartTime = self.startNoteData.timePoint:sub(copyTimePoint)
	self.deltaEndTime = self.endNoteData.timePoint:sub(copyTimePoint)
end

function LongEditorNote:paste(timePoint)
	local ld = self.editorModel.layerData

	self.startNoteData = self.startNoteData:clone()
	self.endNoteData = self.endNoteData:clone()

	self.startNoteData.timePoint = ld:getTimePoint(timePoint:add(self.deltaStartTime))
	self.endNoteData.timePoint = ld:getTimePoint(timePoint:add(self.deltaEndTime))

	self.endNoteData.startNoteData = self.startNoteData
	self.startNoteData.endNoteData = self.endNoteData
end

function LongEditorNote:remove()
	local ld = self.editorModel.layerData

	ld:removeNoteData(self.startNoteData, self.inputType, self.inputIndex)
	ld:removeNoteData(self.endNoteData, self.inputType, self.inputIndex)
end

function LongEditorNote:add()
	local ld = self.editorModel.layerData

	ld:addNoteData(self.startNoteData, self.inputType, self.inputIndex)
	ld:addNoteData(self.endNoteData, self.inputType, self.inputIndex)
end

return LongEditorNote
