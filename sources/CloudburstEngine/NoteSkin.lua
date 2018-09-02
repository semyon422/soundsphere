CloudburstEngine.NoteSkin = createClass(soul.SoulObject)
local NoteSkin = CloudburstEngine.NoteSkin

NoteSkin.load = function(self)
	self.cs = soul.CS:new(
		nil,
		tonumber(self.noteSkinData.cs[1]),
		tonumber(self.noteSkinData.cs[2]),
		tonumber(self.noteSkinData.cs[3]),
		tonumber(self.noteSkinData.cs[4]),
		self.noteSkinData.cs[5]
	)
	
	self.images = {}
	self:loadImages()
end

NoteSkin.loadImages = function(self)
	for inputType in pairs(self.noteSkinData.inputMode) do
		local inputTypeData = self.noteSkinData[inputType]
		for noteType, list in pairs(inputTypeData.image) do
			for _, imagePath in ipairs(list) do
				self.images[imagePath] = love.graphics.newImage(self.directoryPath .. "/" .. imagePath)
			end
		end
	end
end

NoteSkin.speed = 1

NoteSkin.getCS = function(self, note)
	return self.cs
end

NoteSkin.checkNote = function(self, note, suffix)
	local status, err = pcall(function()
		local data = self.noteSkinData[note.startNoteData.inputType]
		local temp
		temp = data.x[note.startNoteData.inputIndex] or error("x")
		temp = data.w[note.startNoteData.inputIndex] or error("w")
		for noteType, list in pairs(data.image) do
			temp = list[note.startNoteData.inputIndex] or error("image list")
			temp = self.images[list[note.startNoteData.inputIndex]] or error("image")
		end
	end)
	
	return status
end

--------------------------------
-- get*Layer
--------------------------------
NoteSkin.getShortNoteLayer = function(self, note)
	return 2 * (1000000 - note.startNoteData.timePoint:getAbsoluteTime()) * (note.startNoteData.inputIndex + 1) / 1000000000 + 16
end
NoteSkin.getLongNoteHeadLayer = function(self, note)
	return self:getShortNoteLayer(note)
end
NoteSkin.getLongNoteTailLayer = function(self, note)
	return self:getShortNoteLayer(note)
end
NoteSkin.getLongNoteBodyLayer = function(self, note)
	return (1000000 - note.startNoteData.timePoint:getAbsoluteTime()) * (note.startNoteData.inputIndex + 1) / 1000000000 - 1 / 2000000000 + 16
end

--------------------------------
-- get*Drawable
--------------------------------
NoteSkin.getNoteDrawable = function(self, note, suffix)
	return self.images[self.noteSkinData[note.startNoteData.inputType].image[note.noteType .. (suffix or "")][note.startNoteData.inputIndex]]
end

--------------------------------
-- get*X get*Y
--------------------------------
NoteSkin.getNoteX = function(self, note)
	return self.noteSkinData[note.startNoteData.inputType].x[note.startNoteData.inputIndex]
end

NoteSkin.getBaseY = function(self, note)
	local value = self.noteSkinData.currentTimePosition
	
	return value or 1
end

NoteSkin.getShortNoteY = function(self, note, suffix)
	return self:getBaseY(note) - self.speed * (note.startNoteData.currentVisualTime - note.engine.currentTime) - self:getNoteHeight(note) / 2
end
NoteSkin.getLongNoteHeadY = function(self, note, suffix)
	return self:getBaseY(note) - self.speed * ((note:getFakeVisualStartTime() or note.startNoteData.currentVisualTime) - note.engine.currentTime) - self:getNoteHeight(note, suffix) / 2
end
NoteSkin.getLongNoteTailY = function(self, note, suffix)
	return self:getBaseY(note) - self.speed * (note.endNoteData.currentVisualTime - note.engine.currentTime) - self:getNoteHeight(note, suffix) / 2
end
NoteSkin.getLongNoteBodyY = function(self, note, suffix)
	return self:getBaseY(note) - self.speed * (note.endNoteData.currentVisualTime - note.engine.currentTime)
end

--------------------------------
-- get*Width get*Height
--------------------------------
NoteSkin.getNoteWidth = function(self, note)
	return self.noteSkinData[note.startNoteData.inputType].w[note.startNoteData.inputIndex]
end

NoteSkin.getNoteHeight = function(self, note, suffix)
	return self:getNoteWidth(note, suffix) / (self:getNoteDrawable(note, suffix):getWidth() / self:getNoteDrawable(note, suffix):getHeight())
end

--------------------------------
-- get*ScaleX get*ScaleY
--------------------------------
NoteSkin.getNoteScaleX = function(self, note, suffix)
	return self:getNoteWidth(note, suffix) / self:getCS(note):x(self:getNoteDrawable(note, suffix):getWidth())
end

NoteSkin.getNoteScaleY = function(self, note, suffix)
	if suffix == "Body" then
		return (self:getLongNoteHeadY(note, suffix) - self:getLongNoteTailY(note, suffix)) / self:getCS(note):y(self:getNoteDrawable(note, suffix):getHeight())
	end
	
	return self:getNoteScaleX(note, suffix)
end

--------------------------------
-- will*Draw
--------------------------------
NoteSkin.willShortNoteDraw = function(self, note)
	local shortNoteY = self:getShortNoteY(note)
	local shortNoteHeight = self:getNoteHeight(note)
	
	return (shortNoteY + shortNoteHeight > 0) and (shortNoteY < 1)
end
NoteSkin.willShortNoteDrawBeforeStart = function(self, note)
	return self:getShortNoteY(note) >= 1
end
NoteSkin.willShortNoteDrawAfterEnd = function(self, note)
	return self:getShortNoteY(note) + self:getNoteHeight(note) <= 0
end

NoteSkin.willLongNoteDraw = function(self, note)
	local longNoteHeadY = self:getLongNoteHeadY(note, "Head")
	local longNoteTailY = self:getLongNoteTailY(note, "Tail")
	local longNoteHeadHeight = self:getNoteHeight(note, "Head")
	local longNoteTailHeight = self:getNoteHeight(note, "Tail")
	
	local willDraw = {}
	
	willDraw.head = longNoteHeadY + longNoteHeadHeight > 0 and longNoteHeadY < 1
	willDraw.tail = longNoteTailY + longNoteTailHeight > 0 and longNoteTailY < 1
	willDraw.body = longNoteHeadY >= 1 and longNoteTailY + longNoteTailHeight <= 0
	
	return willDraw.head or willDraw.tail or willDraw.body
end
NoteSkin.willLongNoteDrawBeforeStart = function(self, note)
	return self:getLongNoteTailY(note, "Tail") >= 1
end
NoteSkin.willLongNoteDrawAfterEnd = function(self, note)
	return self:getLongNoteHeadY(note, "Head") + self:getNoteHeight(note, "Head") <= 0
end

--------------------------------
-- get*Colour
--------------------------------
NoteSkin.getShortNoteColour = function(self, note)
	if note:getLogicalNote().state == "clear" then
		return {255, 255, 255, 255}
	elseif note:getLogicalNote().state == "missed" then
		return {127, 127, 127, 255}
	elseif note:getLogicalNote().state == "passed" then
		return {255, 255, 255, 0}
	end
end

NoteSkin.getLongNoteColour = function(self, note)
	local logicalNote = note:getLogicalNote()
	
	if logicalNote.fakeStartTime and logicalNote.fakeStartTime >= note.endNoteData.timePoint:getAbsoluteTime() then
		return {255, 255, 255, 0}
	elseif logicalNote.state == "clear" then
		return {255, 255, 255, 255}
	elseif logicalNote.state == "startMissed" then
		return {127, 127, 127, 255}
	elseif logicalNote.state == "startMissedPressed" then
		return {191, 191, 191, 255}
	elseif logicalNote.state == "startPassedPressed" then
		return {255, 255, 255, 255}
	elseif logicalNote.state == "endPassed" then
		return {255, 255, 255, 0}
	elseif logicalNote.state == "endMissed" then
		return {127, 127, 127, 255}
	elseif logicalNote.state == "endMissedPassed" then
		return {127, 127, 127, 255}
	end
end
