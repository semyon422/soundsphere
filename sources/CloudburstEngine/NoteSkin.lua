CloudburstEngine.NoteSkin = createClass(soul.SoulObject)
local NoteSkin = CloudburstEngine.NoteSkin

NoteSkin.load = function(self)
	self.filePath = self.directoryPath .. "/" .. self.fileName
	
	self.images = {}
	
	self.config = SpaceConfig:new()
	self.config:init()
	self.config.observable:addObserver(self.observer)
	self.config:load(self.filePath)
	
	self:loadImages()
end

NoteSkin.receiveEvent = function(self, event)
	if event.name == "SpaceConfigAddValue" then
		if event.key[3] == "image" then
			self.images[event.value] = true
		end
	elseif event.name == "SpaceConfigProcessLine" then
		if event.key[1] == "cs" then
			self.cs = soul.CS:new(
				nil,
				tonumber(event.data[1]),
				tonumber(event.data[2]),
				tonumber(event.data[3]),
				tonumber(event.data[4]),
				event.data[5]
			)
		end
	end
end

NoteSkin.loadImages = function(self)
	for imagePath in pairs(self.images) do
		self.images[imagePath] = love.graphics.newImage(self.directoryPath .. "/" .. imagePath)
	end
end

NoteSkin.speed = 1

NoteSkin.getCS = function(self, note)
	return self.cs
end

NoteSkin.checkNote = function(self, note, suffix)
	local key1 = {
		note.inputModeString,
		note.startNoteData.inputType,
		"image",
		note.noteType .. (suffix or "")
	}
	local value1 = self.config:getKeyTable(key1)[note.startNoteData.inputIndex]
	
	local key2 = {
		note.inputModeString,
		note.startNoteData.inputType,
		"x"
	}
	local value2 = self.config:getKeyTable(key2)[note.startNoteData.inputIndex]
	
	local key3 = {
		note.inputModeString,
		note.startNoteData.inputType,
		"w"
	}
	local value3 = self.config:getKeyTable(key3)[note.startNoteData.inputIndex]
	
	
	if value1 and value2 and value3 then
		return true
	end
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
	local key = {
		note.inputModeString,
		note.startNoteData.inputType,
		"image",
		note.noteType .. (suffix or "")
	}
	local value = self.config:getKeyTable(key)[note.startNoteData.inputIndex]
	
	return self.images[value]
end

--------------------------------
-- get*X get*Y
--------------------------------
NoteSkin.getNoteX = function(self, note)
	local key = {
		note.inputModeString,
		note.startNoteData.inputType,
		"x"
	}
	return self.config:getKeyTable(key)[note.startNoteData.inputIndex]
end

NoteSkin.getBaseY = function(self, note)
	local key = {
		note.inputModeString,
		"currentTimePosition"
	}
	local value = self.config:getKeyTable(key)[1]
	
	return value or 1
end

NoteSkin.getShortNoteY = function(self, note, suffix)
	return self:getBaseY(note) - self.speed * (note.startNoteData.currentVisualTime - note.engine.currentTime) - self:getNoteHeight(note) / 2
end
NoteSkin.getLongNoteHeadY = function(self, note, suffix)
	return self:getBaseY(note) - self.speed * ((note:getLogicalNote().fakeStartTime or note.startNoteData.currentVisualTime) - note.engine.currentTime) - self:getNoteHeight(note, suffix) / 2
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
	local key = {
		note.inputModeString,
		note.startNoteData.inputType,
		"w"
	}
	return self.config:getKeyTable(key)[note.startNoteData.inputIndex]
end

NoteSkin.getNoteHeight = function(self, note, suffix)
	return self:getNoteWidth(note, suffix) / (self:getNoteDrawable(note, suffix):getWidth() / self:getNoteDrawable(note, suffix):getHeight())
end

--------------------------------
-- get*ScaleX get*ScaleY
--------------------------------
NoteSkin.getNoteScaleX = function(self, note, suffix)
	return self:getNoteWidth(note, suffix) / self.cs:x(self:getNoteDrawable(note, suffix):getWidth())
end

NoteSkin.getNoteScaleY = function(self, note, suffix)
	if suffix == "Body" then
		return (self:getLongNoteHeadY(note, suffix) - self:getLongNoteTailY(note, suffix)) / self.cs:y(self:getNoteDrawable(note, suffix):getHeight())
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
