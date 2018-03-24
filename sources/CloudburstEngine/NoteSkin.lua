CloudburstEngine.NoteSkin = createClass()
local NoteSkin = CloudburstEngine.NoteSkin

NoteSkin.cs = soul.CS:new(nil, 0, 0, 0, 0, "h")

local root = "resources/NoteSkin/"

NoteSkin.drawables = {
	white = {
		ShortNote = love.graphics.newImage(root .. "shortNote/white.png"),
		LongNoteBody = love.graphics.newImage(root .. "longNoteBody/white/body-0.png"),
		LongNoteHead = love.graphics.newImage(root .. "longNoteHead/white.png"),
		LongNoteTail = love.graphics.newImage(root .. "longNoteTail/white.png")
	},
	blue = {
		ShortNote = love.graphics.newImage(root .. "shortNote/blue.png"),
		LongNoteBody = love.graphics.newImage(root .. "longNoteBody/blue/body-0.png"),
		LongNoteHead = love.graphics.newImage(root .. "longNoteHead/blue.png"),
		LongNoteTail = love.graphics.newImage(root .. "longNoteTail/blue.png")
	},
	yellow = {
		ShortNote = love.graphics.newImage(root .. "shortNote/yellow.png"),
		LongNoteBody = love.graphics.newImage(root .. "longNoteBody/yellow/body-0.png"),
		LongNoteHead = love.graphics.newImage(root .. "longNoteHead/yellow.png"),
		LongNoteTail = love.graphics.newImage(root .. "longNoteTail/yellow.png")
	},
	orange = {
		ShortNote = love.graphics.newImage(root .. "shortNote/orange.png"),
		LongNoteBody = love.graphics.newImage(root .. "longNoteBody/orange/body-0.png"),
		LongNoteHead = love.graphics.newImage(root .. "longNoteHead/orange.png"),
		LongNoteTail = love.graphics.newImage(root .. "longNoteTail/orange.png")
	}
}

NoteSkin.noteWidth = 7 / 9 / 8
NoteSkin.speed = 2

NoteSkin.getCS = function(self, note)
	return self.cs
end

NoteSkin.getColumnIndexNumber = function(self, note)
	if note.noteData.inputType == "scratch" then
		return 0
	else
		return note.noteData.inputIndex
	end
end

NoteSkin.getNoteColor = function(self, inputType, inputIndex, inputCount)
	if inputType == "scratch" then
		return "orange"
	elseif inputType == "key" then
		if inputCount % 2 == 1 then
			local halfInputCount = (inputCount - 1) / 2
			if (inputCount + 1) / 2 == inputIndex then
				return "yellow"
			else
				if (halfInputCount - inputIndex + 1) % 2 == 1 then
					return "white"
				else
					return "blue"
				end
			end
		else
			local halfInputCount = inputCount / 2
			if inputIndex <= inputCount / 2 then
				if (halfInputCount - inputIndex + 1) % 2 == 1 then
					return "white"
				else
					return "blue"
				end
			else
				if (halfInputCount - inputIndex + 1) % 2 == 1 then
					return "blue"
				else
					return "white"
				end
			end
		end
	end
end

--------------------------------
-- get*Layer
--------------------------------
NoteSkin.getShortNoteLayer = function(self, note)
	return 2 * (1000000 - note.noteData.startTimePoint:getAbsoluteTime()) * (self:getColumnIndexNumber(note) + 1) / 1000000000 + 16
end
NoteSkin.getLongNoteHeadLayer = function(self, note)
	return self:getShortNoteLayer(note)
end
NoteSkin.getLongNoteTailLayer = function(self, note)
	return self:getShortNoteLayer(note)
end
NoteSkin.getLongNoteBodyLayer = function(self, note)
	return (1000000 - note.noteData.startTimePoint:getAbsoluteTime()) * (self:getColumnIndexNumber(note) + 1) / 1000000000 - 1 / 2000000000 + 16
end

--------------------------------
-- get*Drawable
--------------------------------
NoteSkin.getShortNoteDrawable = function(self, note)
	return self.drawables[self:getNoteColor(note.noteData.inputType, note.noteData.inputIndex, 7)].ShortNote
end
NoteSkin.getLongNoteHeadDrawable = function(self, note)
	return self.drawables[self:getNoteColor(note.noteData.inputType, note.noteData.inputIndex, 7)].LongNoteHead
end
NoteSkin.getLongNoteTailDrawable = function(self, note)
	return self.drawables[self:getNoteColor(note.noteData.inputType, note.noteData.inputIndex, 7)].LongNoteTail
end
NoteSkin.getLongNoteBodyDrawable = function(self, note)
	return self.drawables[self:getNoteColor(note.noteData.inputType, note.noteData.inputIndex, 7)].LongNoteBody
end

--------------------------------
-- get*X get*Y
--------------------------------
NoteSkin.getShortNoteX = function(self, note)
	return 7 / 9 - self:getNoteWidth(note) * (8 - self:getColumnIndexNumber(note))
end
NoteSkin.getLongNoteHeadX = function(self, note)
	return self:getShortNoteX(note)
end
NoteSkin.getLongNoteTailX = function(self, note)
	return self:getShortNoteX(note)
end
NoteSkin.getLongNoteBodyX = function(self, note)
	return self:getShortNoteX(note)
end

NoteSkin.getShortNoteY = function(self, note)
	return 1 - self.speed * (note.noteData.currentVisualStartTime - note.engine.currentTime) - self:getShortNoteHeight(note) / 2
end
NoteSkin.getLongNoteHeadY = function(self, note)
	return 1 - self.speed * ((note:getLogicalNote().fakeStartTime or note.noteData.currentVisualStartTime) - note.engine.currentTime) - self:getLongNoteHeadHeight(note) / 2
end
NoteSkin.getLongNoteTailY = function(self, note)
	return 1 - self.speed * (note.noteData.currentVisualEndTime - note.engine.currentTime) - self:getLongNoteTailHeight(note) / 2
end
NoteSkin.getLongNoteBodyY = function(self, note)
	return 1 - self.speed * (note.noteData.currentVisualEndTime - note.engine.currentTime)
end

--------------------------------
-- get*Width get*Height
--------------------------------
NoteSkin.getNoteWidth = function(self, note)
	return self.noteWidth
end
NoteSkin.getShortNoteHeight = function(self, note)
	return self:getNoteWidth(note) / (self:getShortNoteDrawable(note):getWidth() / self:getShortNoteDrawable(note):getHeight())
end
NoteSkin.getLongNoteHeadHeight = function(self, note)
	return self:getNoteWidth(note) / (self:getLongNoteHeadDrawable(note):getWidth() / self:getLongNoteHeadDrawable(note):getHeight())
end
NoteSkin.getLongNoteTailHeight = function(self, note)
	return self:getNoteWidth(note) / (self:getLongNoteTailDrawable(note):getWidth() / self:getLongNoteTailDrawable(note):getHeight())
end
NoteSkin.getLongNoteBodyHeight = function(self, note)
	return self:getNoteWidth(note) / (self:getLongNoteBodyDrawable(note):getWidth() / self:getLongNoteBodyDrawable(note):getHeight())
end

--------------------------------
-- get*ScaleX get*ScaleY
--------------------------------
NoteSkin.getShortNoteScaleX = function(self, note)
	return self:getNoteWidth(note) / self.cs:x(self:getShortNoteDrawable(note):getWidth())
end
NoteSkin.getLongNoteHeadScaleX = function(self, note)
	return self:getNoteWidth(note) / self.cs:x(self:getLongNoteHeadDrawable(note):getWidth())
end
NoteSkin.getLongNoteTailScaleX = function(self, note)
	return self:getNoteWidth(note) / self.cs:x(self:getLongNoteTailDrawable(note):getWidth())
end
NoteSkin.getLongNoteBodyScaleX = function(self, note)
	return self:getNoteWidth(note) / self.cs:x(self:getLongNoteBodyDrawable(note):getWidth())
end

NoteSkin.getShortNoteScaleY = function(self, note)
	return self:getShortNoteScaleX(note)
end
NoteSkin.getLongNoteHeadScaleY = function(self, note)
	return self:getLongNoteHeadScaleX(note)
end
NoteSkin.getLongNoteTailScaleY = function(self, note)
	return self:getLongNoteTailScaleX(note)
end
NoteSkin.getLongNoteBodyScaleY = function(self, note)
	return (self:getLongNoteHeadY(note) - self:getLongNoteTailY(note)) / self.cs:y(self:getLongNoteBodyDrawable(note):getHeight())
end

--------------------------------
-- will*Draw
--------------------------------
NoteSkin.willShortNoteDraw = function(self, note)
	local shortNoteY = self:getShortNoteY(note)
	local shortNoteHeight = self:getShortNoteHeight(note)
	
	return (shortNoteY + shortNoteHeight / 2 > 0) and (shortNoteY - shortNoteHeight / 2 < 1)
end
NoteSkin.willShortNoteDrawBeforeStart = function(self, note)
	return self:getShortNoteY(note) - self:getShortNoteHeight(note) / 2 >= 1
end
NoteSkin.willShortNoteDrawAfterEnd = function(self, note)
	return self:getShortNoteY(note) + self:getShortNoteHeight(note) / 2 <= 0
end

NoteSkin.willLongNoteDraw = function(self, note)
	local longNoteHeadY = self:getLongNoteHeadY(note)
	local longNoteTailY = self:getLongNoteTailY(note)
	local longNoteHeadHeight = self:getLongNoteHeadHeight(note)
	local longNoteTailHeight = self:getLongNoteTailHeight(note)
	
	local willDraw = {}
	willDraw.head = longNoteHeadY + longNoteHeadHeight / 2 > 0 and longNoteHeadY - longNoteHeadHeight / 2 < 1
	willDraw.tail = longNoteTailY + longNoteTailHeight / 2 > 0 and longNoteTailY - longNoteTailHeight / 2 < 1
	willDraw.body = longNoteHeadY - longNoteHeadHeight / 2 >= 1 and longNoteTailY + longNoteTailHeight / 2 <= 0
	
	return willDraw.head or willDraw.tail or willDraw.body
end
NoteSkin.willLongNoteDrawBeforeStart = function(self, note)
	return self:getLongNoteTailY(note) - self:getLongNoteTailHeight(note) / 2 >= 1
end
NoteSkin.willLongNoteDrawAfterEnd = function(self, note)
	return self:getLongNoteHeadY(note) + self:getLongNoteHeadHeight(note) / 2 <= 0
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
	if note:getLogicalNote().fakeStartTime and note:getLogicalNote().fakeStartTime >= note.noteData.endTimePoint:getAbsoluteTime() then
		return {255, 255, 255, 0}
	elseif note:getLogicalNote().state == "clear" then
		return {255, 255, 255, 255}
	elseif note:getLogicalNote().state == "startMissed" then
		return {127, 127, 127, 255}
	elseif note:getLogicalNote().state == "startMissedPressed" then
		return {191, 191, 191, 255}
	elseif note:getLogicalNote().state == "startPassedPressed" then
		return {255, 255, 255, 255}
	elseif note:getLogicalNote().state == "endPassed" then
		return {255, 255, 255, 0}
	elseif note:getLogicalNote().state == "endMissed" then
		return {127, 127, 127, 255}
	elseif note:getLogicalNote().state == "endMissedPassed" then
		return {127, 127, 127, 255}
	end
end
