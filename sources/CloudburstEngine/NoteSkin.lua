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
	self.data = {}
	self.images = {}
	for _, line in ipairs(self.noteSkinString:split("#")) do
		self:processLine(line:gsub("\n", " "):trim())
	end
	self:loadImages()
end

NoteSkin.getClearDataTable = function(self, dataTable, removingString)
	local newDataTable = {}
	
	for _, value in ipairs(dataTable) do
		if value ~= removingString then
			table.insert(newDataTable, value)
		end
	end
	
	return newDataTable
end

NoteSkin.getKeyTable = function(self, key)
	local lastKeyTable = self.data
	
	for _, keyString in ipairs(key) do
		lastKeyTable[keyString] = lastKeyTable[keyString] or {}
		lastKeyTable = lastKeyTable[keyString]
	end
	
	return lastKeyTable
end

NoteSkin.setKeyTableData = function(self, keyTable, data)
	for _, value in ipairs(data) do
		if value:find("/") then
			self.images[value] = true
		end
		local value = tonumber((value:gsub(",", "."))) or value
		table.insert(keyTable, value)
	end
end

NoteSkin.processLine = function(self, line)
	if line:find("^.+:.+$") then
		local keyString, dataString = line:match("^(.+):(.+)$")
		local key = self:getClearDataTable(keyString:split("%s+", true), "")
		local data = self:getClearDataTable(dataString:split("%s+", true), "")
		
		self:setKeyTableData(self:getKeyTable(key), data)
		
		if key[1] == "cs" then
			self.cs = soul.CS:new(
				nil,
				tonumber(data[1]),
				tonumber(data[2]),
				tonumber(data[3]),
				tonumber(data[4]),
				data[5]
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
	local a = self.data[note.inputModeString]
	if a then
		local b = a[note.startNoteData.inputType]
		if b then
			local c1 = b[note.noteType .. (suffix or "")]
			local c2 = b["x"]
			local c3 = b["w"]
			if c2 and c2 and c3 then
				local d = c1[note.startNoteData.inputIndex]
				if d then
					return self.images[d]
				end
			end
		end
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
	return self.images[
		self.data
		[note.inputModeString]
		[note.startNoteData.inputType]
		[note.noteType .. (suffix or "")]
		[note.startNoteData.inputIndex]
	]
end

--------------------------------
-- get*X get*Y
--------------------------------
NoteSkin.getNoteX = function(self, note)
	return self.data
		[note.inputModeString]
		[note.startNoteData.inputType]
		["x"]
		[note.startNoteData.inputIndex]
end

NoteSkin.getShortNoteY = function(self, note, suffix)
	return 1 - self.speed * (note.startNoteData.currentVisualTime - note.engine.currentTime) - self:getNoteHeight(note) / 2
end
NoteSkin.getLongNoteHeadY = function(self, note, suffix)
	return 1 - self.speed * ((note:getLogicalNote().fakeStartTime or note.startNoteData.currentVisualTime) - note.engine.currentTime) - self:getNoteHeight(note, suffix) / 2
end
NoteSkin.getLongNoteTailY = function(self, note, suffix)
	return 1 - self.speed * (note.endNoteData.currentVisualTime - note.engine.currentTime) - self:getNoteHeight(note, suffix) / 2
end
NoteSkin.getLongNoteBodyY = function(self, note, suffix)
	return 1 - self.speed * (note.endNoteData.currentVisualTime - note.engine.currentTime)
end

--------------------------------
-- get*Width get*Height
--------------------------------
NoteSkin.getNoteWidth = function(self, note)
	return self.data
		[note.inputModeString]
		[note.startNoteData.inputType]
		["w"]
		[note.startNoteData.inputIndex]
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
