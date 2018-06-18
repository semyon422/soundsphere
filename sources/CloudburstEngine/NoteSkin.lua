CloudburstEngine.NoteSkin = createClass()
local NoteSkin = CloudburstEngine.NoteSkin

NoteSkin.load = function(self, directoryPath, fileName)
	self.directoryPath, self.fileName = directoryPath, fileName
	self.filePath = directoryPath .. "/" .. fileName
	
	self:readFile()
	self:processFile()
end

NoteSkin.readFile = function(self)
	local noteSkinFile = io.open(self.filePath, "r")
	self.noteSkinString = noteSkinFile:read("*a")
	noteSkinFile:close()
end

NoteSkin.processFile = function(self)
	self.variables = {}
	self.notes = {}
	for _, line in ipairs(self.noteSkinString:split("\n")) do
		self:processLine(line:trim())
	end
	self:loadImages()
end

NoteSkin.processLine = function(self, line)
	if line:find("^#%S+:.+$") then
		local key, value = line:match("^#(%S+):(.+)$")
		self.variables[key] = value
	elseif line:find("^#%S+ .+$") then
		local type, dataString = line:match("^#(%S+) (.+)$")
		local data = dataString:split(" ")
		if type == "note" then
			local id = data[1]
			self.notes[id] = {}
			
			self.notes[id].x = tonumber(self.variables[data[2] or 0]) or 0
			self.notes[id].w = tonumber(self.variables[data[3] or 0]) or 0
			self.notes[id].imagePath = self.variables[data[4] or 0]
		elseif type == "cs" then
			self.cs = soul.CS:new(
				nil,
				tonumber(data[1]),
				tonumber(data[2]),
				tonumber(data[3]),
				tonumber(data[4]),
				data[5]
			)
		elseif type == "playfield" then
			self.playfield = dataString
		end
	end
end

NoteSkin.loadImages = function(self)
	self.images = {}
	for noteId, data in pairs(self.notes) do
		if data.imagePath and not self.images[data.imagePath] then
			self.images[data.imagePath] = love.graphics.newImage(self.directoryPath .. "/" .. data.imagePath)
		end
	end
	
	self.drawables = {}
	for noteId, data in pairs(self.notes) do
		if data.imagePath then
			self.drawables[noteId] = self.images[data.imagePath]
		end
	end
end

NoteSkin.speed = 2

NoteSkin.getCS = function(self, note)
	return self.cs
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
NoteSkin.getShortNoteDrawable = function(self, note)
	return self.drawables[note.id]
end
NoteSkin.getLongNoteHeadDrawable = function(self, note)
	return self.drawables[note.id .. "Head"]
end
NoteSkin.getLongNoteTailDrawable = function(self, note)
	return self.drawables[note.id .. "Tail"]
end
NoteSkin.getLongNoteBodyDrawable = function(self, note)
	return self.drawables[note.id .. "Body"]
end

--------------------------------
-- get*X get*Y
--------------------------------
NoteSkin.getShortNoteX = function(self, note)
	return self.notes[note.id].x
end
NoteSkin.getLongNoteHeadX = function(self, note)
	return self.notes[note.id .. "Head"].x
end
NoteSkin.getLongNoteTailX = function(self, note)
	return self.notes[note.id .. "Tail"].x
end
NoteSkin.getLongNoteBodyX = function(self, note)
	return self.notes[note.id .. "Body"].x
end

NoteSkin.getShortNoteY = function(self, note)
	return 1 - self.speed * (note.startNoteData.currentVisualTime - note.engine.currentTime) - self:getShortNoteHeight(note) / 2
end
NoteSkin.getLongNoteHeadY = function(self, note)
	return 1 - self.speed * ((note:getLogicalNote().fakeStartTime or note.startNoteData.currentVisualTime) - note.engine.currentTime) - self:getLongNoteHeadHeight(note) / 2
end
NoteSkin.getLongNoteTailY = function(self, note)
	return 1 - self.speed * (note.endNoteData.currentVisualTime - note.engine.currentTime) - self:getLongNoteTailHeight(note) / 2
end
NoteSkin.getLongNoteBodyY = function(self, note)
	return 1 - self.speed * (note.endNoteData.currentVisualTime - note.engine.currentTime)
end

--------------------------------
-- get*Width get*Height
--------------------------------
NoteSkin.getShortNoteWidth = function(self, note)
	return self.notes[note.id].w
end
NoteSkin.getLongNoteHeadWidth = function(self, note)
	return self.notes[note.id .. "Head"].w
end
NoteSkin.getLongNoteTailWidth = function(self, note)
	return self.notes[note.id .. "Tail"].w
end
NoteSkin.getLongNoteBodyWidth = function(self, note)
	return self.notes[note.id .. "Body"].w
end

NoteSkin.getShortNoteHeight = function(self, note)
	return self:getShortNoteWidth(note) / (self:getShortNoteDrawable(note):getWidth() / self:getShortNoteDrawable(note):getHeight())
end
NoteSkin.getLongNoteHeadHeight = function(self, note)
	return self:getLongNoteHeadWidth(note) / (self:getLongNoteHeadDrawable(note):getWidth() / self:getLongNoteHeadDrawable(note):getHeight())
end
NoteSkin.getLongNoteTailHeight = function(self, note)
	return self:getLongNoteTailWidth(note) / (self:getLongNoteTailDrawable(note):getWidth() / self:getLongNoteTailDrawable(note):getHeight())
end
NoteSkin.getLongNoteBodyHeight = function(self, note)
	return self:getLongNoteBodyWidth(note) / (self:getLongNoteBodyDrawable(note):getWidth() / self:getLongNoteBodyDrawable(note):getHeight())
end

--------------------------------
-- get*ScaleX get*ScaleY
--------------------------------
NoteSkin.getShortNoteScaleX = function(self, note)
	return self:getShortNoteWidth(note) / self.cs:x(self:getShortNoteDrawable(note):getWidth())
end
NoteSkin.getLongNoteHeadScaleX = function(self, note)
	return self:getLongNoteHeadWidth(note) / self.cs:x(self:getLongNoteHeadDrawable(note):getWidth())
end
NoteSkin.getLongNoteTailScaleX = function(self, note)
	return self:getLongNoteTailWidth(note) / self.cs:x(self:getLongNoteTailDrawable(note):getWidth())
end
NoteSkin.getLongNoteBodyScaleX = function(self, note)
	return self:getLongNoteBodyWidth(note) / self.cs:x(self:getLongNoteBodyDrawable(note):getWidth())
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
	
	return (shortNoteY + shortNoteHeight > 0) and (shortNoteY < 1)
end
NoteSkin.willShortNoteDrawBeforeStart = function(self, note)
	return self:getShortNoteY(note) >= 1
end
NoteSkin.willShortNoteDrawAfterEnd = function(self, note)
	return self:getShortNoteY(note) + self:getShortNoteHeight(note) <= 0
end

NoteSkin.willLongNoteDraw = function(self, note)
	local longNoteHeadY = self:getLongNoteHeadY(note)
	local longNoteTailY = self:getLongNoteTailY(note)
	local longNoteHeadHeight = self:getLongNoteHeadHeight(note)
	local longNoteTailHeight = self:getLongNoteTailHeight(note)
	
	local willDraw = {}
	
	willDraw.head = longNoteHeadY + longNoteHeadHeight > 0 and longNoteHeadY < 1
	willDraw.tail = longNoteTailY + longNoteTailHeight > 0 and longNoteTailY < 1
	willDraw.body = longNoteHeadY >= 1 and longNoteTailY + longNoteTailHeight <= 0
	
	return willDraw.head or willDraw.tail or willDraw.body
end
NoteSkin.willLongNoteDrawBeforeStart = function(self, note)
	return self:getLongNoteTailY(note) >= 1
end
NoteSkin.willLongNoteDrawAfterEnd = function(self, note)
	return self:getLongNoteHeadY(note) + self:getLongNoteHeadHeight(note) <= 0
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
