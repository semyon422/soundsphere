CloudburstEngine.NoteSkin = createClass(soul.SoulObject)
local NoteSkin = CloudburstEngine.NoteSkin

NoteSkin.load = function(self)
	self.allcs = soul.CS:new(nil, 0, 0, 0, 0, "all")
	
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
				if not self.images[imagePath] then
					self.images[imagePath] = love.graphics.newImage(self.directoryPath .. "/" .. imagePath)
				end
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
		temp = data.y[note.startNoteData.inputIndex] or error("y")
		temp = data.w[note.startNoteData.inputIndex] or error("w")
		temp = data.h[note.startNoteData.inputIndex] or error("h")
		temp = data.fx[note.startNoteData.inputIndex] or error("fx")
		temp = data.fy[note.startNoteData.inputIndex] or error("fy")
		temp = data.ox[note.startNoteData.inputIndex] or error("ox")
		temp = data.oy[note.startNoteData.inputIndex] or error("oy")
		temp = data.lnox[note.startNoteData.inputIndex] or error("lnox")
		temp = data.lnoy[note.startNoteData.inputIndex] or error("lnoy")
		temp = data.lnw[note.startNoteData.inputIndex] or error("lnw")
		temp = data.lnh[note.startNoteData.inputIndex] or error("lnh")
		temp = data.layer[note.startNoteData.inputIndex] or error("layer")
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
	local layer = self.noteSkinData[note.startNoteData.inputType].layer[note.startNoteData.inputIndex]
	return
		layer
		+ map(
			note.startNoteData.timePoint:getAbsoluteTime(),
			note.startNoteData.timePoint.firstTimePoint:getAbsoluteTime(),
			note.startNoteData.timePoint.lastTimePoint:getAbsoluteTime(),
			0.5,
			1
		)
end
NoteSkin.getLongNoteHeadLayer = function(self, note)
	return self:getShortNoteLayer(note)
end
NoteSkin.getLongNoteTailLayer = function(self, note)
	return self:getShortNoteLayer(note)
end
NoteSkin.getLongNoteBodyLayer = function(self, note)
	local layer = self.noteSkinData[note.startNoteData.inputType].layer[note.startNoteData.inputIndex]
	return
		layer
		+ map(
			note.startNoteData.timePoint:getAbsoluteTime(),
			note.startNoteData.timePoint.firstTimePoint:getAbsoluteTime(),
			note.startNoteData.timePoint.lastTimePoint:getAbsoluteTime(),
			0,
			0.5
		)
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
NoteSkin.getShortNoteX = function(self, note, suffix)
	local x = self.noteSkinData[note.startNoteData.inputType].x[note.startNoteData.inputIndex]
	local ox = self.noteSkinData[note.startNoteData.inputType].ox[note.startNoteData.inputIndex]
	local fx = self.noteSkinData[note.startNoteData.inputType].fx[note.startNoteData.inputIndex]
	local dt = note.startNoteData.currentVisualTime - note.engine.currentTime
	return
		x
		+ fx * self.speed * dt
		+ ox * self:getNoteWidth(note, suffix)
end
NoteSkin.getLongNoteHeadX = function(self, note, suffix)
	local x = self.noteSkinData[note.startNoteData.inputType].x[note.startNoteData.inputIndex]
	local ox = self.noteSkinData[note.startNoteData.inputType].ox[note.startNoteData.inputIndex]
	local fx = self.noteSkinData[note.startNoteData.inputType].fx[note.startNoteData.inputIndex]
	local dt = (note:getFakeVisualStartTime() or note.startNoteData.currentVisualTime) - note.engine.currentTime
	return
		x
		+ fx * self.speed * dt
		+ ox * self:getNoteWidth(note, suffix)
end
NoteSkin.getLongNoteTailX = function(self, note, suffix)
	local x = self.noteSkinData[note.startNoteData.inputType].x[note.startNoteData.inputIndex]
	local ox = self.noteSkinData[note.startNoteData.inputType].ox[note.startNoteData.inputIndex]
	local fx = self.noteSkinData[note.startNoteData.inputType].fx[note.startNoteData.inputIndex]
	local dt = note.endNoteData.currentVisualTime - note.engine.currentTime
	return
		x
		+ fx * self.speed * dt
		+ ox * self:getNoteWidth(note, suffix)
end
NoteSkin.getLongNoteBodyX = function(self, note, suffix)
	local x = self.noteSkinData[note.startNoteData.inputType].x[note.startNoteData.inputIndex]
	local lnox = self.noteSkinData[note.startNoteData.inputType].lnox[note.startNoteData.inputIndex]
	local fx = self.noteSkinData[note.startNoteData.inputType].fx[note.startNoteData.inputIndex]
	local dt = note.endNoteData.currentVisualTime - note.engine.currentTime
	return
		x
		+ fx * self.speed * dt
		+ lnox * self:getNoteWidth(note, "Tail")
end

NoteSkin.getShortNoteY = function(self, note, suffix)
	local y = self.noteSkinData[note.startNoteData.inputType].y[note.startNoteData.inputIndex]
	local oy = self.noteSkinData[note.startNoteData.inputType].oy[note.startNoteData.inputIndex]
	local fy = self.noteSkinData[note.startNoteData.inputType].fy[note.startNoteData.inputIndex]
	local dt = note.startNoteData.currentVisualTime - note.engine.currentTime
	return
		y
		+ fy * self.speed * dt
		+ oy * self:getNoteHeight(note, suffix)
end
NoteSkin.getLongNoteHeadY = function(self, note, suffix)
	local y = self.noteSkinData[note.startNoteData.inputType].y[note.startNoteData.inputIndex]
	local oy = self.noteSkinData[note.startNoteData.inputType].oy[note.startNoteData.inputIndex]
	local fy = self.noteSkinData[note.startNoteData.inputType].fy[note.startNoteData.inputIndex]
	local dt = (note:getFakeVisualStartTime() or note.startNoteData.currentVisualTime) - note.engine.currentTime
	return
		y
		+ fy * self.speed * dt
		+ oy * self:getNoteHeight(note, suffix)
end
NoteSkin.getLongNoteTailY = function(self, note, suffix)
	local y = self.noteSkinData[note.startNoteData.inputType].y[note.startNoteData.inputIndex]
	local oy = self.noteSkinData[note.startNoteData.inputType].oy[note.startNoteData.inputIndex]
	local fy = self.noteSkinData[note.startNoteData.inputType].fy[note.startNoteData.inputIndex]
	local dt = note.endNoteData.currentVisualTime - note.engine.currentTime
	return
		y
		+ fy * self.speed * dt
		+ oy * self:getNoteHeight(note, suffix)
end
NoteSkin.getLongNoteBodyY = function(self, note, suffix)
	local y = self.noteSkinData[note.startNoteData.inputType].y[note.startNoteData.inputIndex]
	local lnoy = self.noteSkinData[note.startNoteData.inputType].lnoy[note.startNoteData.inputIndex]
	local fy = self.noteSkinData[note.startNoteData.inputType].fy[note.startNoteData.inputIndex]
	local dt = note.endNoteData.currentVisualTime - note.engine.currentTime
	return
		y
		+ fy * self.speed * dt
		+ lnoy * self:getNoteHeight(note, "Tail")
end

--------------------------------
-- get*Width get*Height
--------------------------------
NoteSkin.getNoteWidth = function(self, note)
	return self.noteSkinData[note.startNoteData.inputType].w[note.startNoteData.inputIndex]
end

NoteSkin.getNoteHeight = function(self, note, suffix)
	return self.noteSkinData[note.startNoteData.inputType].h[note.startNoteData.inputIndex]
end

--------------------------------
-- get*ScaleX get*ScaleY
--------------------------------
NoteSkin.getNoteScaleX = function(self, note, suffix)
	if suffix == "Body" then
		return
			(
				math.abs(self:getLongNoteHeadX(note, suffix) - self:getLongNoteTailX(note, suffix))
				+ self.noteSkinData[note.startNoteData.inputType].lnw[note.startNoteData.inputIndex]
			) / self:getCS(note):x(self:getNoteDrawable(note, suffix):getWidth())
	end
	
	return self:getNoteWidth(note, suffix) / self:getCS(note):x(self:getNoteDrawable(note, suffix):getWidth())
end

NoteSkin.getNoteScaleY = function(self, note, suffix)
	if suffix == "Body" then
		return
			math.abs(
				math.abs(self:getLongNoteHeadY(note, suffix) - self:getLongNoteTailY(note, suffix))
				+ self.noteSkinData[note.startNoteData.inputType].lnh[note.startNoteData.inputIndex]
			) / self:getCS(note):y(self:getNoteDrawable(note, suffix):getHeight())
	end
	
	return self:getNoteHeight(note, suffix) / self:getCS(note):y(self:getNoteDrawable(note, suffix):getHeight())
end

--------------------------------
-- will*Draw
--------------------------------
NoteSkin.willShortNoteDraw = function(self, note)
	local shortNoteY = self:getShortNoteY(note)
	local shortNoteHeight = self:getNoteHeight(note)
	local shortNoteX = self:getShortNoteX(note)
	local shortNoteWidth = self:getNoteWidth(note)
	
	return
		(self.allcs:x(self.cs:X(shortNoteX + shortNoteWidth, true), true) > 0) and (self.allcs:x(self.cs:X(shortNoteX, true), true) < 1) and
		(self.allcs:y(self.cs:Y(shortNoteY + shortNoteHeight, true), true) > 0) and (self.allcs:y(self.cs:Y(shortNoteY, true), true) < 1)
end
NoteSkin.willShortNoteDrawBeforeStart = function(self, note)
	local shortNoteY = self:getShortNoteY(note)
	local shortNoteX = self:getShortNoteX(note)
	
	return
		(self.allcs:x(self.cs:X(shortNoteX, true), true) >= 1) or
		(self.allcs:y(self.cs:Y(shortNoteY, true), true) >= 1)
end
NoteSkin.willShortNoteDrawAfterEnd = function(self, note)
	local shortNoteY = self:getShortNoteY(note)
	local shortNoteHeight = self:getNoteHeight(note)
	local shortNoteX = self:getShortNoteX(note)
	local shortNoteWidth = self:getNoteWidth(note)
	
	return
		(self.allcs:x(self.cs:X(shortNoteX + shortNoteWidth, true), true) <= 0) or
		(self.allcs:y(self.cs:Y(shortNoteY + shortNoteHeight, true), true) <= 0)
end

NoteSkin.willLongNoteDraw = function(self, note)
	local longNoteHeadX = self:getLongNoteHeadY(note, "Head")
	local longNoteHeadY = self:getLongNoteHeadY(note, "Head")
	local longNoteTailX = self:getLongNoteTailY(note, "Tail")
	local longNoteTailY = self:getLongNoteTailY(note, "Tail")
	local longNoteHeadWidth = self:getNoteHeight(note, "Head")
	local longNoteHeadHeight = self:getNoteHeight(note, "Head")
	local longNoteTailWidth = self:getNoteHeight(note, "Tail")
	local longNoteTailHeight = self:getNoteHeight(note, "Tail")
	
	local willDraw = {}
	
	willDraw.head = 
		(self.allcs:x(self.cs:X(longNoteHeadX + longNoteHeadWidth, true), true) > 0) and (self.allcs:x(self.cs:X(longNoteHeadX, true), true) < 1) and
		(self.allcs:y(self.cs:Y(longNoteHeadY + longNoteHeadHeight, true), true) > 0) and (self.allcs:y(self.cs:Y(longNoteTailY, true), true) < 1)
	willDraw.tail = 
		(self.allcs:x(self.cs:X(longNoteTailX + longNoteTailWidth, true), true) > 0) and (self.allcs:x(self.cs:X(longNoteTailX, true), true) < 1) and
		(self.allcs:y(self.cs:Y(longNoteTailY + longNoteTailHeight, true), true) > 0) and (self.allcs:y(self.cs:Y(longNoteTailY, true), true) < 1)
	willDraw.body = 
		(self.allcs:x(self.cs:X(longNoteTailX + longNoteTailWidth, true), true) < 0) and (self.allcs:x(self.cs:X(longNoteHeadX, true), true) >= 1) and
		(self.allcs:y(self.cs:Y(longNoteTailY + longNoteTailHeight, true), true) < 0) and (self.allcs:y(self.cs:Y(longNoteHeadY, true), true) >= 1)
	
	return willDraw.head or willDraw.tail or willDraw.body
end
NoteSkin.willLongNoteDrawBeforeStart = function(self, note)
	local longNoteTailX = self:getLongNoteTailY(note, "Tail")
	local longNoteTailY = self:getLongNoteTailY(note, "Tail")
	
	return
		(self.allcs:x(self.cs:X(longNoteTailX, true), true) >= 1) or
		(self.allcs:y(self.cs:Y(longNoteTailY, true), true) >= 1)
end
NoteSkin.willLongNoteDrawAfterEnd = function(self, note)
	local longNoteHeadX = self:getLongNoteHeadY(note, "Head")
	local longNoteHeadY = self:getLongNoteHeadY(note, "Head")
	local longNoteHeadWidth = self:getNoteHeight(note, "Head")
	local longNoteHeadHeight = self:getNoteHeight(note, "Head")
	
	return
		(self.allcs:x(self.cs:X(longNoteHeadX + longNoteHeadWidth, true), true) <= 0) or
		(self.allcs:y(self.cs:Y(longNoteHeadY + longNoteHeadHeight, true), true) <= 0)
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
